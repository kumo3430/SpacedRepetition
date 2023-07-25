<?php
session_unset();
session_destroy();
session_start();
// 獲取用戶提交的表單數據
$input_data = file_get_contents("php://input");
$data = json_decode($input_data, true);

// 取得用戶名和密碼
$userName = $data['userName'];
$email = $data['email'];
$password = $data['password'];

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
$sql2 = "SELECT * FROM `User` WHERE `userName` = '7pp'";
$result = $conn->query($sql2);
if ($result->num_rows > 0) {
    // 輸出每行數據
    while ($row = $result->fetch_assoc()) {
        $_SESSION['uid'] = $row['id'];
        echo $row['id'];
    }
} else {
    $message = "no such account";
}
$conn->close();
?>