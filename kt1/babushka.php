<?php
echo "ЧЕГО СКАЗАТЬ-ТО ХОТЕЛ, МИЛОК?!\n";

// Основной цикл программы
$continue_talking = true;
$user_input = "";

while ($continue_talking) {
    // получаем ввод
    echo "> ";
    $user_input = trim(fgets(STDIN));
    
    // проверяем "пока!"
    if ($user_input == "пока!" || $user_input == "ПОКА!") {
        echo "ДО СВИДАНИЯ, МИЛЫЙ! СМОТРИ НЕ КУРИ И ШАПКУ НАДЕНЬ!\n";
        $continue_talking = false;
        break;
    }
    
    // проверка "!" на конце 
    $last_char = substr($user_input, -1);
    $is_shouting = ($last_char == "!");
    
    if ($is_shouting) {
        // кричим и бабушка отвечает 
        $random_year = rand(1930, 1950);
        echo "НЕТ, НИ РАЗУ С " . $random_year . " ГОДА!\n";
    } else {
        // не кричим, бабушка не слышит
        echo "АСЬ?! ГОВОРИ ГРОМЧЕ, ВНУЧЕК!\n";
    }
}


?>
