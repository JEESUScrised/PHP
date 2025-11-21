<?php
session_start();

$length = rand(5, 6);
$characters = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
$captchaCode = '';
for ($i = 0; $i < $length; $i++) {
    $captchaCode .= $characters[rand(0, strlen($characters) - 1)];
}

$_SESSION['captcha_code'] = $captchaCode;

$backgroundImage = imagecreatefromjpeg('noise.jpg');
if (!$backgroundImage) {
    die('Ошибка загрузки фона');
}

$width = imagesx($backgroundImage);
$height = imagesy($backgroundImage);

$image = imagecreatetruecolor($width, $height);
imagecopy($image, $backgroundImage, 0, 0, 0, 0, $width, $height);

$textColors = [
    imagecolorallocate($image, 0, 0, 0),
    imagecolorallocate($image, 50, 50, 50),
    imagecolorallocate($image, 0, 0, 100),
    imagecolorallocate($image, 100, 0, 0),
];

$fontPath = 'C:\\Windows\\Fonts\\arial.ttf';

if (!file_exists($fontPath)) {
    $fontPath = 'C:\\Windows\\Fonts\\times.ttf';
}
if (!file_exists($fontPath)) {
    $fontPath = 'C:\\Windows\\Fonts\\calibri.ttf';
}

$fontSize = rand(18, 30);
$maxCharWidth = $fontSize * 0.7;
$spacing = min(40, ($width - 40) / $length);
$totalWidth = ($length - 1) * $spacing + $maxCharWidth;
$startX = max(20, ($width - $totalWidth) / 2);
$startY = $height / 2 + $fontSize / 2;

$minY = $fontSize + 10;
$maxY = $height - 10;

for ($i = 0; $i < $length; $i++) {
    $char = $captchaCode[$i];
    
    $textColor = $textColors[rand(0, count($textColors) - 1)];
    
    $angle = rand(-15, 15);
    
    $x = $startX + ($i * $spacing);
    
    $yOffset = rand(-5, 5);
    $y = $startY + $yOffset;
    
    if ($y < $minY) {
        $y = $minY;
    } elseif ($y > $maxY) {
        $y = $maxY;
    }
    
    if ($x + $maxCharWidth > $width - 10) {
        $x = $width - $maxCharWidth - 10;
    }
    if ($x < 10) {
        $x = 10;
    }
    
    if (file_exists($fontPath)) {
        imagettftext($image, $fontSize, $angle, $x, $y, $textColor, $fontPath, $char);
    } else {
        imagestring($image, 5, $x, $y - 15, $char, $textColor);
    }
}

header('Content-Type: image/jpeg');
header('Cache-Control: no-cache, no-store, must-revalidate');
header('Pragma: no-cache');
header('Expires: 0');

imagejpeg($image, null, 90);

imagedestroy($image);
imagedestroy($backgroundImage);
?>

