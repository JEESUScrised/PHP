<!DOCTYPE html>
<html lang="ru">
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>Книжный магазин</title>
	<link rel='stylesheet' href='/css/style.css'>
	<style>
		/* Анимированная сетка на фоне */
		body {
			position: relative;
		}
		
		.grid-background {
			position: fixed;
			top: 0;
			left: 0;
			width: 100%;
			height: 100%;
			pointer-events: none;
			z-index: -1;
			background: #000000;
			opacity: 1;
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
		
		/* Дополнительный эффект свечения */
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
		
		/* Глитч кнопка */
		.glitch-button {
			position: relative;
			display: inline-flex;
			align-items: center;
			justify-content: center;
			padding: 8px 20px;
			background: var(--bg-secondary);
			border: 1px solid var(--border-color);
			border-radius: var(--border-radius);
			color: var(--text-primary);
			font-family: 'Courier New', monospace;
			font-size: 0.9em;
			font-weight: 600;
			letter-spacing: 2px;
			cursor: pointer;
			overflow: hidden;
			transition: var(--transition);
			text-decoration: none;
			min-width: 140px;
			text-align: center;
			vertical-align: middle;
			line-height: 1.5;
			height: auto;
		}
		
		.glitch-button:hover {
			border-color: var(--accent-color);
			box-shadow: 0 0 10px rgba(74, 144, 226, 0.3);
		}
		
		.glitch-text {
			display: inline-block;
			position: relative;
		}
		
		.glitch-char {
			display: inline-block;
			transition: none;
		}
		
		@keyframes glitch {
			0%, 100% {
				transform: translate(0);
			}
			20% {
				transform: translate(-1px, 1px);
			}
			40% {
				transform: translate(-1px, -1px);
			}
			60% {
				transform: translate(1px, 1px);
			}
			80% {
				transform: translate(1px, -1px);
			}
		}
		
		.glitch-button:hover .glitch-char {
			animation: glitch 0.1s infinite;
		}
	</style>
	<script>
		// Глитч эффект для кнопки
		document.addEventListener('DOMContentLoaded', function() {
			const glitchButtons = document.querySelectorAll('.glitch-button');
			const glitchChars = ['№', '@', '*', '^', '&', '$', '|', '?', '0', '1'];
			
			glitchButtons.forEach(button => {
				const glitchText = button.querySelector('.glitch-text');
				if (!glitchText) return;
				
				const originalText = glitchText.textContent;
				const chars = originalText.split('');
				const charElements = [];
				
				// Создаем элементы для каждого символа
				glitchText.innerHTML = '';
				chars.forEach((char, index) => {
					const span = document.createElement('span');
					span.className = 'glitch-char';
					span.textContent = char;
					span.dataset.original = char;
					span.dataset.index = index;
					glitchText.appendChild(span);
					charElements.push(span);
				});
				
				// Функция случайного символа (отличного от текущего)
				function getRandomChar(currentChar) {
					let newChar;
					do {
						newChar = glitchChars[Math.floor(Math.random() * glitchChars.length)];
					} while (newChar === currentChar && glitchChars.length > 1);
					return newChar;
				}
				
				// Функция случайного цвета для глитча
				const glitchColors = ['#ffffff', '#000000'];
				function getRandomColor() {
					return glitchColors[Math.floor(Math.random() * glitchColors.length)];
				}
				
				// Постоянная быстрая смена символов - без остановки
				let constantGlitchInterval = setInterval(() => {
					// Меняем все символы постоянно, не возвращаем к оригинальным
					charElements.forEach((element, index) => {
						// Случайно решаем, менять ли этот символ (80% вероятность)
						if (Math.random() < 0.8) {
							const newChar = glitchChars[Math.floor(Math.random() * glitchChars.length)];
							element.textContent = newChar;
							element.style.color = getRandomColor();
						}
					});
				}, 30); // 30ms между сменами - постоянная смена
				
				// Усиленный глитч при наведении - все символы меняются быстрее
				let hoverGlitchInterval;
				button.addEventListener('mouseenter', () => {
					hoverGlitchInterval = setInterval(() => {
						// Меняем все символы при наведении (100% вероятность)
						charElements.forEach((element) => {
							const newChar = glitchChars[Math.floor(Math.random() * glitchChars.length)];
							element.textContent = newChar;
							element.style.color = getRandomColor();
						});
					}, 15); // 15ms (быстрее при наведении)
				});
				
				button.addEventListener('mouseleave', () => {
					if (hoverGlitchInterval) {
						clearInterval(hoverGlitchInterval);
					}
					// Восстанавливаем все символы
					charElements.forEach(element => {
						element.textContent = element.dataset.original;
						element.style.color = '';
					});
				});
			});
		});
	</script>
</head>
<body>
	<div class="grid-background">
		<div class="grid-pattern"></div>
		<div class="grid-glow"></div>
		<div class="grid-shimmer"></div>
	</div>