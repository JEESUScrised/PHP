<?php
// Страница с анимацией черепа
?>
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <meta http-equiv="Pragma" content="no-cache">
    <meta http-equiv="Expires" content="0">
    <title>Череп</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@700&display=swap" rel="stylesheet">
    <style>
        * {
            margin: 0 !important;
            padding: 0 !important;
            box-sizing: border-box !important;
        }
        html, body {
            height: 100% !important;
            margin: 0 !important;
            padding: 0 !important;
            background: #000000 !important;
            color: #ffffff !important;
            overflow: hidden !important;
            font-family: monospace !important;
        }
        
        body {
            display: flex !important;
            align-items: center !important;
            justify-content: center !important;
            position: relative !important;
            padding-top: 120px !important;
        }
        
        #back-button {
            position: fixed;
            top: 20px;
            left: 20px;
            z-index: 1000;
        }
        
        #trace {
            width: 100% !important;
            max-width: 75vw !important;
            max-height: 85vh !important;
            font-family: monospace !important;
            margin: 0 !important;
            padding: 0 !important;
            background: transparent !important;
            color: #ffffff !important;
            text-align: center !important;
            overflow: hidden !important;
        }
        
        #trace-chars {
            white-space: pre;
        }
        
        .animated-title {
            text-align: center;
            margin-bottom: 30px;
            z-index: 10;
            position: fixed;
            top: 20px;
            left: 50%;
            transform: translateX(-50%);
            width: 100%;
        }
        
        .animated-title h1 {
            font-family: 'JetBrains Mono', 'Monocraft', 'Courier New', monospace;
            font-size: 2em;
            font-weight: 700;
            color: #ffffff;
            margin: 0;
            padding: 0;
            text-transform: uppercase;
            letter-spacing: 5px;
            overflow: hidden;
            border-right: 3px solid #fff;
            white-space: nowrap;
        }
        
        .animated-title h1.typing-complete {
            border-right: none;
        }
        
        .animated-title h2 {
            font-family: 'JetBrains Mono', 'Monocraft', 'Courier New', monospace;
            font-size: 1.2em;
            font-weight: 700;
            color: #ffffff;
            margin: 10px 0 0 0;
            padding: 0;
            letter-spacing: 3px;
            overflow: hidden;
            border-right: 3px solid #fff;
            white-space: nowrap;
            opacity: 0;
        }
        
        .animated-title h2.typing-complete {
            border-right: none;
            opacity: 1;
        }
        
        @keyframes blink-cursor {
            0%, 50% { border-color: transparent; }
            51%, 100% { border-color: inherit; }
        }
        
        .animated-title h1.typing,
        .animated-title h2.typing {
            animation: blink-cursor 0.8s infinite;
        }
        
        @keyframes glitch-text {
            0%, 100% {
                transform: translate(0);
                text-shadow: 0 0 10px rgba(255, 255, 255, 0.5);
            }
            20% {
                transform: translate(-2px, 2px);
                text-shadow: -2px 2px 10px rgba(74, 144, 226, 0.8);
            }
            40% {
                transform: translate(-2px, -2px);
                text-shadow: -2px -2px 10px rgba(74, 144, 226, 0.8);
            }
            60% {
                transform: translate(2px, 2px);
                text-shadow: 2px 2px 10px rgba(74, 144, 226, 0.8);
            }
            80% {
                transform: translate(2px, -2px);
                text-shadow: 2px -2px 10px rgba(74, 144, 226, 0.8);
            }
        }
        
        @keyframes pulse-glow {
            0%, 100% {
                opacity: 0.8;
                text-shadow: 0 0 5px rgba(74, 144, 226, 0.5);
            }
            50% {
                opacity: 1;
                text-shadow: 0 0 20px rgba(74, 144, 226, 1), 0 0 30px rgba(74, 144, 226, 0.8);
            }
        }
        
        .grid-background {
            position: fixed !important;
            top: 0 !important;
            left: 0 !important;
            width: 100% !important;
            height: 100% !important;
            pointer-events: none !important;
            z-index: -1 !important;
            background: #000000 !important;
            opacity: 1 !important;
        }
        
        .grid-pattern {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-image: 
                linear-gradient(rgba(255, 255, 255, 0.1) 1px, transparent 1px),
                linear-gradient(90deg, rgba(255, 255, 255, 0.1) 1px, transparent 1px);
            background-size: 50px 50px;
            animation: gridMove 20s linear infinite;
            filter: blur(0.5px);
        }
        
        .grid-glow {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-image: 
                linear-gradient(rgba(255, 255, 255, 0.15) 1px, transparent 1px),
                linear-gradient(90deg, rgba(255, 255, 255, 0.15) 1px, transparent 1px);
            background-size: 50px 50px;
            animation: gridMove 20s linear infinite reverse;
            filter: blur(1px);
            opacity: 0.6;
        }
        
        @keyframes gridMove {
            0% {
                transform: translate(0, 0);
            }
            100% {
                transform: translate(50px, 50px);
            }
        }
        
        .grid-shimmer {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: 
                radial-gradient(circle at 20% 30%, rgba(255, 255, 255, 0.03) 0%, transparent 30%),
                radial-gradient(circle at 80% 70%, rgba(255, 255, 255, 0.02) 0%, transparent 30%);
            animation: shimmerMove 15s ease-in-out infinite;
        }
        
        @keyframes shimmerMove {
            0%, 100% {
                transform: translate(0, 0);
                opacity: 0.5;
            }
            50% {
                transform: translate(10%, -10%);
                opacity: 0.8;
            }
        }
        
        .link-button {
            display: inline-flex;
            align-items: center;
            padding: 8px 20px;
            background: #1a1a1a;
            border: 1px solid #333333;
            border-radius: 4px;
            color: #e0e0e0;
            text-decoration: none;
            transition: all 0.2s ease;
            font-weight: 400;
        }
        
        .link-button:hover {
            background: #2a2a2a;
            border-color: #4a90e2;
            color: #e0e0e0;
        }
    </style>
</head>
<body>
    <div class="grid-background">
        <div class="grid-pattern"></div>
        <div class="grid-glow"></div>
        <div class="grid-shimmer"></div>
    </div>
    
    <div id="back-button">
        <a href="/catalog" class="link-button">← Назад</a>
    </div>
    
    <div class="animated-title">
        <h1 id="title-line1"></h1>
        <h2 id="title-line2"></h2>
    </div>
    
    <pre id="trace">
        <span id="trace-chars"></span>
    </pre>

    <script>
        <?php
        // Загружаем frames.js через PHP
        // Определяем путь к файлу frames.js
        $baseDir = dirname(__DIR__); // eshop/
        
        // Пробуем разные варианты путей
        $projectRoot = dirname(dirname(__DIR__)); // Корень проекта (kt3/)
        $possiblePaths = [
            $baseDir . DIRECTORY_SEPARATOR . 'skull' . DIRECTORY_SEPARATOR . 'frames.js',
            $projectRoot . DIRECTORY_SEPARATOR . 'skull' . DIRECTORY_SEPARATOR . 'frames.js',
            __DIR__ . DIRECTORY_SEPARATOR . '..' . DIRECTORY_SEPARATOR . 'skull' . DIRECTORY_SEPARATOR . 'frames.js',
            '/var/www/eshop/skull/frames.js',
            '/var/www/eshop/skull-data/frames.js',
        ];
        
        $framesFile = null;
        foreach ($possiblePaths as $path) {
            if ($path && file_exists($path) && is_readable($path)) {
                $framesFile = $path;
                break;
            }
        }
        
        if ($framesFile && file_exists($framesFile) && is_readable($framesFile)) {
            // Читаем файл полностью
            $content = @file_get_contents($framesFile);
            if ($content !== false && strlen($content) > 0) {
                // Проверяем начало файла
                $trimmed = trim($content);
                if (strpos($trimmed, 'const frames') === 0 || strpos($trimmed, 'var frames') === 0) {
                    // Экранируем закрывающие теги скрипта
                    $content = str_replace('</script>', '<\/script>', $content);
                    // Выводим содержимое напрямую
                    echo $content;
                } else {
                    echo "console.error('Invalid frames.js format. First 100 chars: " . addslashes(substr($trimmed, 0, 100)) . "');";
                    echo "var frames = [];";
                }
            } else {
                echo "console.error('Failed to read frames.js file or file is empty');";
                echo "var frames = [];";
            }
        } else {
            // Если файл не найден, выводим ошибку с отладочной информацией
            echo "console.error('frames.js not found in any of the following paths:');";
            foreach ($possiblePaths as $path) {
                echo "console.error('  - " . addslashes($path) . "');";
            }
            echo "var frames = [];";
        }
        ?>
    </script>
    <script>
        // Функция fitTextToContainer (из оригинального кода)
        function fitTextToContainer(text, fontFace, containerWidth) {
            const PIXEL_RATIO = getPixelRatio();

            let canvas = createHiDPICanvas(containerWidth, 0),
                context = canvas.getContext('2d'),
                longestLine = getLongestLine(split(text)),
                fittedFontSize = getFittedFontSize(longestLine, fontFace);

            return fittedFontSize;

            function getPixelRatio() {
                let ctx = document.createElement("canvas").getContext("2d"),
                    dpr = window.devicePixelRatio || 1,
                    bsr = ctx.webkitBackingStorePixelRatio ||
                          ctx.mozBackingStorePixelRatio ||
                          ctx.msBackingStorePixelRatio ||
                          ctx.oBackingStorePixelRatio ||
                          ctx.backingStorePixelRatio || 1;
                return dpr / bsr;
            }

            function split(text) {
                return text.split('\n');
            }

            function getLongestLine(lines) {
                let longest = -1, i;
                lines.forEach((line, ii) => {
                    let lineWidth = context.measureText(line).width;
                    if (lineWidth > longest) {
                        i = ii;
                        if (!line.includes('exempt-from-text-fit-calculation')) {
                            longest = lineWidth;
                        }
                    }
                });
                return ('number' === typeof i) ? lines[i] : null;
            }

            function getFittedFontSize(text, fontFace) {
                const fits = () => context.measureText(text).width <= canvas.width;
                const font = (size, face) => size + "px " + face;
                let fontSize = 300;
                do {
                    fontSize--;
                    context.font = font(fontSize, fontFace);
                } while(!fits());
                fontSize /= (PIXEL_RATIO / 1.62);
                return fontSize;
            }

            function createHiDPICanvas(w, h) {
                let canvas = document.createElement("canvas");
                canvas.width = w * PIXEL_RATIO;
                canvas.height = h * PIXEL_RATIO;
                canvas.style.width = w + "px";
                canvas.style.height = h + "px";
                canvas.getContext("2d").setTransform(PIXEL_RATIO, 0, 0, PIXEL_RATIO, 0, 0);
                return canvas;
            }
        }

        // Эффект печати для заголовков
        function typeWriter(element, text, speed, callback) {
            element.textContent = '';
            element.classList.add('typing');
            let i = 0;
            function type() {
                if (i < text.length) {
                    element.textContent += text.charAt(i);
                    i++;
                    setTimeout(type, speed);
                } else {
                    element.classList.remove('typing');
                    element.classList.add('typing-complete');
                    if (callback) callback();
                }
            }
            type();
        }
        
        // Запускаем эффект печати при загрузке страницы
        function initTypewriter() {
            const title1 = document.getElementById('title-line1');
            const title2 = document.getElementById('title-line2');
            
            if (title1 && title2) {
                // Первая строка
                typeWriter(title1, 'By JEESUScrised', 80, function() {
                    // Вторая строка после завершения первой
                    setTimeout(function() {
                        title2.style.opacity = '1';
                        typeWriter(title2, 'HolyBibleGroup', 60, null);
                    }, 300);
                });
            }
        }
        
        var pre = document.getElementById('trace');
        var i = 0;
        var max = 0;
        var fps = 26;

        // Ждем загрузки frames перед вызовом setPreCharSize
        function initAnimation() {
            if (typeof frames === 'undefined' || !frames || frames.length === 0) {
                console.log('Waiting for frames...', typeof frames);
                setTimeout(initAnimation, 50);
                return;
            }
            max = frames.length;
            console.log('Frames loaded:', max);
            setPreCharSize();
            startAnimating();
        }

        window.addEventListener('resize', function() {
            // Проверяем, что frames загружен перед вызовом setPreCharSize
            if (typeof frames !== 'undefined' && frames && frames.length > 0) {
                setPreCharSize();
            }
        });

        function setPreCharSize() {
            if (typeof frames === 'undefined' || !frames || frames.length === 0) {
                console.warn('setPreCharSize: frames not loaded yet');
                return;
            }
            var charRatio = 0.55;
            var firstFrame = frames[0];
            if (!firstFrame || typeof firstFrame !== 'string') {
                console.warn('setPreCharSize: firstFrame is invalid', typeof firstFrame);
                return;
            }
            var lines = firstFrame.split('\n');
            if (lines.length < 2) {
                console.warn('setPreCharSize: not enough lines in first frame', lines.length);
                return;
            }
            try {
                var charWidth = fitTextToContainer(lines[1], 'monospace', pre.clientWidth) * charRatio;
                var charHeight = charRatio * charWidth;
                pre.style.fontSize = charWidth + "px";
                pre.style.lineHeight = charHeight + "px";
            } catch (e) {
                console.error('setPreCharSize error:', e);
            }
        }

        // initialize the timer variables and start the animation
        var fpsInterval, startTime, now, then, elapsed;
        function startAnimating() {
            if (max === 0) {
                console.error('Cannot start animation: frames not loaded');
                return;
            }
            fpsInterval = 1000 / fps;
            then = Date.now();
            startTime = then;
            animate();
        }

        // Инициализация после загрузки всех скриптов
        // Используем DOMContentLoaded для гарантии загрузки
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', function() {
                initTypewriter();
                initAnimation();
            });
        } else {
            initTypewriter();
            initAnimation();
        }

        // the animation loop calculates time elapsed since the last loop
        // and only draws if your specified fps interval is achieved
        function animate() {
            // request another frame
            requestAnimationFrame(animate);

            // calc elapsed time since last loop
            now = Date.now();
            elapsed = now - then;

            // if enough time has elapsed, draw the next frame
            if (elapsed > fpsInterval) {
                // get ready for next frame by setting then=now, but also adjust for your
                // specified fpsInterval not being a multiple of RAF's interval (16.7ms)
                then = now - (elapsed % fpsInterval);

                // step
                step();
            }
        }

        function step() {
            // Непрерывное вращение: увеличиваем индекс и используем модуль для зацикливания
            i = (i + 1) % max;
            document.getElementById('trace-chars').innerText = frames[i];
        }
    </script>
</body>
</html>

