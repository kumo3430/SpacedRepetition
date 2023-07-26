<?php
session_unset();
session_destroy();
session_start();
// 獲取用戶提交的表單數據
$input_data = file_get_contents("php://input");
$data = json_decode($input_data, true);

// 取得用戶名和密碼
// $userName = $data['userName'];
$email = $data['email'];
$password = $data['password'];
$create_at = $data['create_at'];

$servername = "localhost"; // 資料庫伺服器名稱

$servername = "localhost"; // 資料庫伺服器名稱
$user = "kumo"; // 資料庫使用者名稱
$pass = "coco3430"; // 資料庫使用者密碼
$dbname = "spaced"; // 資料庫名稱

// 建立與 MySQL 資料庫的連接
$conn = new mysqli($servername, $user, $pass, $dbname);

// 檢查連接是否成功
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
$emailExistSql = "SELECT * FROM `User` WHERE `email` = '$email'";
$result = $conn->query($emailExistSql);
if ($result->num_rows > 0) {
    $emailExist = true;
}

if ($emailExist) {
    $message = "email is registered";
} else if ($nameExist) {
    $message = "name is registered";
} else {
    if ($email != "" && $password != "") {
        $sql = "INSERT INTO `User` (`email`, `password`, `create_at`) VALUES ('$email', '$password','$create_at')";
        if ($conn->query($sql) === TRUE) {
            // 註冊成功，回傳 JSON 格式的訊息
            $message = "User registered successfully";
        } else {
            // 註冊失敗，回傳 JSON 格式的錯誤訊息
            $message = 'Error: ' . $sql . '<br>' . $conn->error;
        }

        $sql2 = "SELECT * FROM `User` WHERE `email` = '$email'";
        $result = $conn->query($sql2);
        if ($result->num_rows <= 0) {
            $message = "no such account";
        } else {
            while ($row = $result->fetch_assoc()) {
                $_SESSION['uid'] = $row['id'];
                $uid = $row['id'];
            }
        }
    }
}

$userData = array(
    'userId' => $uid,
    'email' => $email,
    'password' => $password,
    'create_at' => $create_at,
    'message' => $message
);
echo json_encode($userData);

$conn->close();
?>