const WSDL_URL = document.querySelector('script[src$="travelClient.js"]').getAttribute('data-wsdl-url');
const CONTEXT_PATH = document.querySelector('script[src$="travelClient.js"]').getAttribute('data-context-path') || '/travel-client';
let userId = sessionStorage.getItem('userId');
let userRole = sessionStorage.getItem('userRole');

function showMessage(elementId, message, isError = true) {
    const element = document.getElementById(elementId);
    if (element) {
        element.textContent = message;
        element.className = `mt-4 ${isError ? 'text-red-500' : 'text-green-500'}`;
    }
}

async function callSoap(method, params) {
    return new Promise((resolve, reject) => {
        soap.createClient(WSDL_URL, (err, client) => {
            if (err) return reject(err);
            client[method](params, (err, result) => {
                if (err) return reject(err);
                resolve(result);
            });
        });
    });
}

async function login() {
    const username = document.getElementById('login-username').value;
    const password = document.getElementById('login-password').value;
    try {
        const result = await callSoap('login', { username, password });
        const response = result.return.$value.split(':');
        if (response[0] === 'success') {
            userId = parseInt(response[1]);
            userRole = response[2];
            sessionStorage.setItem('userId', userId);
            sessionStorage.setItem('userRole', userRole);
            showMessage('auth-message', 'Login successful! Redirecting...', false);
            setTimeout(() => {
                window.location.href = CONTEXT_PATH + '/index.jsp';
            }, 1000);
        } else {
            showMessage('auth-message', 'Login failed. Invalid credentials.');
        }
    } catch (err) {
        showMessage('auth-message', 'Error during login.');
    }
}

async function register() {
    const username = document.getElementById('register-username').value;
    const password = document.getElementById('register-password').value;
    const role = document.getElementById('register-role').value;
    try {
        const result = await callSoap('register', { username, password, role });
        showMessage('auth-message', result.return.$value ? 'Registration successful! Please login.' : 'Registration failed.', !result.return.$value);
    } catch (err) {
        showMessage('auth-message', 'Error during registration.');
    }
}

function logout() {
    userId = null;
    userRole = null;
    sessionStorage.removeItem('userId');
    sessionStorage.removeItem('userRole');
    window.location.href = CONTEXT_PATH + '/index.jsp';
}

async function searchPlaces() {
    const keyword = document.getElementById('search-keyword').value;
    try {
        const result = await callSoap('searchPlaces', { keyword });
        document.getElementById('search-results').textContent = result.return.$value;
    } catch (err) {
        document.getElementById('search-results').textContent = 'Error searching places.';
    }
}

async function addPlace() {
    const name = document.getElementById('add-place-name').value;
    const description = document.getElementById('add-place-description').value;
    try {
        const result = await callSoap('addPlace', { name, description, guideId: userId });
        showMessage('guide-message', result.return.$value ? 'Place added successfully!' : 'Failed to add place.', !result.return.$value);
    } catch (err) {
        showMessage('guide-message', 'Error adding place.');
    }
}

async function updatePlace() {
    const placeId = parseInt(document.getElementById('update-place-id').value);
    const name = document.getElementById('update-place-name').value;
    const description = document.getElementById('update-place-description').value;
    try {
        const result = await callSoap('updatePlace', { placeId, name, description, guideId: userId });
        showMessage('guide-message', result.return.$value ? 'Place updated successfully!' : 'Failed to update place.', !result.return.$value);
    } catch (err) {
        showMessage('guide-message', 'Error updating place.');
    }
}

async function deletePlace() {
    const placeId = parseInt(document.getElementById('delete-place-id').value);
    try {
        const result = await callSoap('deletePlace', { placeId, guideId: userId });
        showMessage('guide-message', result.return.$value ? 'Place deleted successfully!' : 'Failed to delete place.', !result.return.$value);
    } catch (err) {
        showMessage('guide-message', 'Error deleting place.');
    }
}

async function addImage() {
    const placeId = parseInt(document.getElementById('add-image-place-id').value);
    const url = document.getElementById('add-image-url').value;
    const description = document.getElementById('add-image-description').value;
    try {
        const result = await callSoap('addImage', { placeId, url, description, guideId: userId });
        showMessage('guide-message', result.return.$value ? 'Image added successfully!' : 'Failed to add image.', !result.return.$value);
    } catch (err) {
        showMessage('guide-message', 'Error adding image.');
    }
}

async function ratePlace() {
    const placeId = parseInt(document.getElementById('rate-place-id').value);
    const rating = parseInt(document.getElementById('rate-value').value);
    const comment = document.getElementById('rate-comment').value;
    if (isNaN(rating) || rating < 1 || rating > 5) {
        showMessage('traveler-message', 'Rating must be between 1 and 5.');
        return;
    }
    try {
        const result = await callSoap('ratePlace', { placeId, travelerId: userId, rating, comment });
        showMessage('traveler-message', result.return.$value ? 'Rating submitted successfully!' : 'Failed to submit rating.', !result.return.$value);
    } catch (err) {
        showMessage('traveler-message', 'Error submitting rating.');
    }
}

async function getImagesByPlace() {
    const placeId = parseInt(document.getElementById('view-images-place-id').value);
    try {
        const result = await callSoap('getImagesByPlace', { placeId });
        document.getElementById('images-results').textContent = result.return.$value;
    } catch (err) {
        document.getElementById('images-results').textContent = 'Error retrieving images.';
    }
}

function checkGuideAccess() {
    if (!userId || userRole !== 'guide') {
        alert('Access denied. Please login as a guide.');
        window.location.href = '/login.jsp';
    }
}

function checkTravelerAccess() {
    if (!userId || userRole !== 'traveler') {
        alert('Access denied. Please login as a traveler.');
        window.location.href = '/login.jsp';
    }
}