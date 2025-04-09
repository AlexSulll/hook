import numpy as np
# (1)
def gcd(a, b):
    if b == 0:
        print(f"НОД равен {a}")
        return a
    else:
        q = a // b
        r = a % b
        print(f"{a} / {b} = {q} ост {r}")
        return gcd(b, r)

# (2)
def print_row(q, r, s, t, col_width=10):
    print(f"{q:^{col_width}}│ {r:^{col_width}}│ {s:^{col_width}}│ {t:^{col_width}}")

def extended_gcd_pretty(a, b):
    # Инициализация списков
    r = [a, b]
    s = [1, 0]
    t = [0, 1]
    q = []
    steps = []
    
    # Выполняем шаги алгоритма
    while True:
        current_b = r[-1]
        if current_b == 0:
            break
        q_i = r[-2] // current_b
        r_i = r[-2] % current_b
        
        # Вычисляем новые коэффициенты s и t
        s_i = s[-2] - s[-1] * q_i
        t_i = t[-2] - t[-1] * q_i
        
        # Сохраняем шаг
        steps.append({
            "q": q_i,
            "r": r_i,
            "s": s_i,
            "t": t_i
        })
        
        # Добавляем новые значения в списки
        q.append(q_i)
        r.append(r_i)
        s.append(s_i)
        t.append(t_i)
    
    # Форматирование таблицы
    col_width = 12
    header = f"{'q_i':^{col_width}}│ {'r_i':^{col_width}}│ {'s_i':^{col_width}}│ {'t_i':^{col_width}}"
    separator = "─" * col_width + "┼" + "─" * (col_width + 1) + "┼" + "─" * (col_width + 1) + "┼" + "─" * col_width
    
    print(header)
    print(separator)
    
    # Первые две строки
    print_row("-", r[0], s[0], t[0], col_width)
    print_row("-", r[1], s[1], t[1], col_width)
    print(separator)
    
    # Последующие строки
    for i, step in enumerate(steps):
        r_val = step['r']
        s_val = step['s'] if r_val != 0 else "-"
        t_val = step['t'] if r_val != 0 else "-"
        print_row(step['q'], step['r'], s_val, t_val, col_width)
        print(separator)
    
    # Получаем НОД и коэффициенты
    gcd = r[-2]
    s_final = s[-2]
    t_final = t[-2]
    
    # Форматируем ответ
    print(f"\nОтвет: {a} * ({s_final}) + {b} * ({t_final}) = {gcd}")
    return gcd, s_final, t_final
# (3)
def find_inverse(a, modulus):
    # Используем ранее созданную функцию для получения коэффициентов
    gcd, s, t = extended_gcd_pretty(a, modulus)
    
    # Проверяем, существует ли обратный элемент
    if gcd != 1:
        print(f"Обратного элемента не существует: НОД({a}, {modulus}) = {gcd}")
        return None
    
    # Приводим коэффициент к положительному виду в кольце вычетов
    inverse = s % modulus
    
    # Выводим результат
    print(f"\nОбратный элемент к {a} по модулю {modulus}: {inverse}")
    return inverse

# (4)
def matrix_check_invertibility(matrix_str, mod=34):
    elements = list(map(int, matrix_str.split()))
    n = int(len(elements) ** 0.5)

    if n * n != len(elements):
        print("Ошибка: Размерность матрицы не является квадратом.")
        return

    A = np.array(elements).reshape(n, n)
    print("Исходная матрица:")
    print(A)

    det = int(round(np.linalg.det(A))) % mod
    print(f"\nОпределитель det(A) = {det} (mod {mod})")

    if det == 0:
        print("Матрица вырождена (det = 0) => обратной не существует.")
        return

    print("\nПроверка взаимной простоты det и mod:")
    find_inverse(det, mod)

# (5) 
def hill_cipher(text, matrix_str, mod=34):
    russian_alphabet = [
        'А', 'Б', 'В', 'Г', 'Д', 'Е', 'Ё', 'Ж', 'З', 'И', 'Й',
        'К', 'Л', 'М', 'Н', 'О', 'П', 'Р', 'С', 'Т', 'У', 'Ф',
        'Х', 'Ц', 'Ч', 'Ш', 'Щ', 'Ъ', 'Ы', 'Ь', 'Э', 'Ю', 'Я', ' '
    ]

    def char_to_num(c):
        c = c.upper()
        if c == 'Ё':
            return 6
        try:
            return russian_alphabet.index(c)
        except ValueError:
            raise ValueError(f"Символ '{c}' не найден в алфавите")

    def num_to_char(n):
        return russian_alphabet[n]

    # Парсинг матрицы
    matrix = list(map(int, matrix_str.split()))
    matrix_size = int(len(matrix)**0.5)

    # Проверка на квадратную матрицу
    if matrix_size * matrix_size != len(matrix):
        print("Ошибка: Матрица не квадратная")
        return

    matrix_2d = [matrix[i * matrix_size:(i + 1) * matrix_size] for i in range(matrix_size)]
    print(f"A = {matrix_2d}\n")

    # Преобразование текста в числовой формат
    try:
        numeric = [char_to_num(c) for c in text.upper()]
    except ValueError as e:
        print(e)
        return

    # Дополнение пробелами
    padding = (-len(numeric)) % matrix_size
    numeric += [33] * padding  # код символа ' '

    # Разбиение на блоки
    blocks = [numeric[i:i + matrix_size] for i in range(0, len(numeric), matrix_size)]

    # Шифрование блоков
    encrypted = []
    for i, block in enumerate(blocks):
        print(f"e{i+1} = {block}")

        cipher_block = []
        for col in range(matrix_size):  # Проходим по столбцам матрицы
            total = 0
            for row in range(matrix_size):  # Умножаем вектор-строку на столбец
                total += block[row] * matrix_2d[row][col]
            cipher_block.append(total % mod)

        print(f"c{i+1} = {cipher_block}\n")
        encrypted.extend(cipher_block)

    # Преобразование в текст
    ciphertext = ''.join(num_to_char(n) for n in encrypted)
    print(f"Зашифрованный текст: {ciphertext}")
    return ciphertext

# (6)
def hill_decrypt(ciphertext, matrix_str, mod=34):
    russian_alphabet = [
        'А', 'Б', 'В', 'Г', 'Д', 'Е', 'Ё', 'Ж', 'З', 'И', 'Й',
        'К', 'Л', 'М', 'Н', 'О', 'П', 'Р', 'С', 'Т', 'У', 'Ф',
        'Х', 'Ц', 'Ч', 'Ш', 'Щ', 'Ъ', 'Ы', 'Ь', 'Э', 'Ю', 'Я', ' '
    ]

    def char_to_num(c):
        c = c.upper()
        try:
            return russian_alphabet.index(c)
        except ValueError:
            raise ValueError(f"Символ '{c}' не найден в алфавите")

    def num_to_char(n):
        return russian_alphabet[n % mod]

    def mod_inv(a, mod):
        g, x, y = extended_gcd(a, mod)
        if g != 1:
            return None
        return x % mod

    def extended_gcd(a, b):
        if b == 0:
            return (a, 1, 0)
        else:
            g, x, y = extended_gcd(b, a % b)
            return (g, y, x - (a // b) * y)

    def matrix_inverse_mod(matrix, mod):
        n = len(matrix)
        det = int(round(np.linalg.det(matrix))) % mod
        det_inv = mod_inv(det, mod)
        if det_inv is None:
            raise ValueError("Обратной матрицы не существует (определитель и модуль не взаимно простые)")

        minors = np.zeros((n, n), dtype=int)
        for i in range(n):
            for j in range(n):
                minor = np.delete(np.delete(matrix, i, 0), j, 1)
                minors[i][j] = (-1)**(i+j) * int(round(np.linalg.det(minor))) % mod

        adjugate = minors.T
        inv = (adjugate * det_inv) % mod
        return np.where(inv < 0, inv + mod, inv)

    # Парсинг матрицы и вычисление обратной
    matrix = list(map(int, matrix_str.split()))
    size = int(len(matrix)**0.5)
    matrix = np.array(matrix).reshape(size, size)

    inv_matrix = matrix_inverse_mod(matrix, mod)
    print("Обратная матрица A^{-1}:")
    print(inv_matrix, '\n')

    # Преобразование шифртекста в числовой формат
    cipher_nums = [char_to_num(c) for c in ciphertext]

    # Разбиение на блоки
    blocks = [cipher_nums[i:i + size] for i in range(0, len(cipher_nums), size)]

    # Расшифровка блоков
    plain_nums = []
    for i, block in enumerate(blocks):
        print(f"c{i+1} = {block}")
        row_vector = np.array(block)
        decrypted = (row_vector @ inv_matrix) % mod  # Вектор-строка * обратная матрица
        print(f"e{i+1} = {decrypted}\n")
        plain_nums.extend(decrypted)

    # Преобразование в текст
    plaintext = ''.join(num_to_char(int(n)) for n in plain_nums)
    print(f"Расшифрованный текст: {plaintext}")
    return plaintext

def main():
    while True:
        print("\n" + "="*40)
        print("Выберите задание:")
        print("1. Нахождение НОД двух чисел")
        print("2. Расширенный алгоритм Евклида")
        print("3. Обратный элемент в кольце вычетов")
        print("4. Обратная матрица по модулю")
        print("5. Шифрование Хилла")
        print("6. Дешифрование Хилла")
        print("0. Выход")
        choice = input("Ваш выбор (0-6): ")

        if choice == "0":
            print("Выход из программы.")
            break
            
        elif choice == "1":
            a = int(input("Первое число: "))
            b = int(input("Второе число: "))
            gcd(a, b)
            
        elif choice == "2":
            a = int(input("Первое число: "))
            b = int(input("Второе число: "))
            extended_gcd_pretty(a, b)
            
        elif choice == "3":
            num = int(input("Число: "))
            mod = int(input("Модуль: "))
            find_inverse(num, mod)
            
        elif choice == "4":
            print("Введите матрицу в формате: 13 5 9 11 9 11 7 6 13 18 10 5 7 3 10 15")
            matrix_str = input("Матрица: ")
            matrix_check_invertibility(matrix_str, mod=34)
            
        elif choice == "5":
            print("Введите матрицу в формате: 13 5 9 11 9 11 7 6 13 18 10 5 7 3 10 15")
            A = input("A = ")
            message = input("Открытый текст: ")
            hill_cipher(message, A)
            
        elif choice == "6":
            print("Введите матрицу в формате: 13 5 9 11 9 11 7 6 13 18 10 5 7 3 10 15")
            A = input("A = ")
            ciphertext = input("Шифр текст: ")
            hill_decrypt(ciphertext, A)
            
        else:
            print("Неверный выбор! Попробуйте снова.")

if __name__ == "__main__":
    main()
