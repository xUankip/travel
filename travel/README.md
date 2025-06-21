
# Hướng Dẫn Làm Việc Với Dự Án

## Cấu Trúc Dự Án

Clone **repository tổng** về, trong đó có 2 thư mục con:

- `travel` — server
- `travel-client` — client

> Sau khi clone, bạn **phải mở từng thư mục con riêng biệt** để chạy.  
**Không thể chạy trực tiếp ở thư mục tổng.**

---

## Làm Việc Với Git

### ✅ Các bước **checkout** và **commit**

> Sử dụng terminal và `cd` vào thư mục cha chứa cả `travel` và `travel-client`.  
**Không `cd` vào từng thư mục con.**

Vẫn sử dụng IDE (IntelliJ/VSCode...) để chạy 2 phần **server/client riêng biệt**.

> Khi checkout sang nhánh mới ở thư mục tổng, **2 thư mục con sẽ tự động chuyển theo nhánh mới.**

---

## 🧩 Hướng Dẫn Sử Dụng Git

### 🔹 BƯỚC 1: LẤY CODE MỚI NHẤT

Luôn luôn thực hiện lệnh:

```bash
git pull origin main
```

Nếu đang ở nhánh khác:

```bash
git checkout main
```

---

> Nếu không làm việc với `main`, bạn sẽ làm việc với 2 nhánh chính: `beta` và `prod`.

- **Tất cả các nhánh mới phải được tạo từ nhánh `prod`.**
- ❌ KHÔNG tạo nhánh mới từ `beta`.

> Nếu không hiểu, hỏi lại để tránh sai sót.

- `beta` là nơi để mọi người test, có thể tự đẩy code lên.
- Nhưng **beta phải luôn hoạt động**, không được để **“bãi cứt” bị chết**.

---

- `prod` là nhánh chính, sau khi test kỹ ở `beta`, phải **tạo Pull Request để merge vào `prod`.**
- ❌ **KHÔNG BAO GIỜ ĐƯỢC TỰ Ý ẤN MERGE**

---

### 🔹 BƯỚC 2: TẠO NHÁNH MỚI

Luôn tạo nhánh mới từ `main` với code mới nhất:

```bash
git checkout -b ten-nhanh
```

Ví dụ:

```bash
git checkout -b xuan/feature#001-tao-moi-user
```

> Trước khi tạo nhánh, hãy tạo thẻ mới trong **Trello → To Do** để đặt tên nhánh.

---

### 🔹 BƯỚC 3: LÀM VIỆC TRÊN NHÁNH MỚI

---

### 🔹 BƯỚC 4: HOÀN THÀNH CHỨC NĂNG

Sau khi test xong chức năng trên nhánh mới, chạy các lệnh sau:

```bash
4.1: git status
# Kiểm tra các file đã thay đổi

4.2: git add ten-file
# Hạn chế dùng: git add . nếu chưa quen

4.3: git commit -m "nội dung commit"
# Có thể viết tiếng Việt, ví dụ: "Chức năng thêm mới user"

4.4: git push origin ten-nhanh
```

> Nếu không dùng được lệnh `git push`, có thể dùng công cụ tích hợp trong IDE (VD: Rider) để push.

---

### 🔹 BƯỚC 5: TẠO PULL REQUEST

1. Lên GitHub → tạo Pull Request với nhánh vừa push.
2. Chọn:
   - **Base**: `main`
   - **Compare**: nhánh bạn vừa làm
3. Bấm: **Create Pull Request**

---

### 🔹 BƯỚC 6: HOÀN THÀNH

Copy đường link Pull Request (trên thanh URL) → dán vào **thẻ đã tạo trên Trello**.

---

## ⚠️ LƯU Ý

> ❌ **KHÔNG BAO GIỜ ĐƯỢC TỰ Ý MERGE CODE VÀO NHÁNH MAIN.**
