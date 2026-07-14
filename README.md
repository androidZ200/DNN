# Diffractive Neural Network (DNN)

Фреймворк для проектирования и обучения дифракционных нейронных сетей на языке MATLAB. Этот проект предоставляет модульный набор классов для построения любых оптических систем с возможностью обучения через обратное распространение ошибки.

## 📋 Содержание

- [Быстрый старт](#быстрый-старт)
- [Архитектура системы](#архитектура-системы)
- [Основные классы](#основные-классы)
  - [Базовые компоненты](#базовые-компоненты)
  - [Распространение волн](#распространение-волн)
  - [Дифракционные элементы (DOE)](#дифракционные-элементы-doe)
  - [Выходные слои](#выходные-слои)
  - [Функции ошибок](#функции-ошибок)
  - [Оптимизаторы](#оптимизаторы)
- [Примеры использования](#примеры-использования)
- [Построение оптических систем](#построение-оптических-систем)

---

## Быстрый старт

### Требования
- MATLAB R2020b или новее
- (Опционально) NVIDIA GPU для ускорения вычислений

### Инициализация

```matlab
addpath(genpath(pwd));  % Добавить все пути проекта

% Включить GPU (если доступен)
global is_gpu;
is_gpu = true;
```

Все рабочие примеры находятся в файле `script_ex.m`.

---

## Архитектура системы

Фреймворк использует **архитектуру цепочки** (chain pattern), где каждый компонент оптической системы содержит ссылку на предыдущий слой и может быть обучен через обратное распространение ошибки.

```
Input → Propagator → DOE (trainable) → Propagator → Output
   ↓                                               ↓
   error_back (обратное распространение ошибки)
```

Все основные классы наследуют от `Prop` и реализуют методы:
- `get_field(input)` - прямой проход
- `set_error_field(error)` - обратный проход
- `gradient_step(speed)` - обновление параметров
- `output_mesh()` / `input_mesh()` - управление координатной сеткой

---

## Основные классы

### Базовые компоненты

#### `Mesh` - Координатная сетка
**Назначение:** Определяет пространственную дискретизацию оптической системы.

**Параметры:**
- `pixel` - размер пикселя в метрах (одно число или [Px, Py])
- `N` - количество точек сетки (одно число или [Nx, Ny])

**Методы:**
- `Mesh.X` - координаты по оси X (Nx × 1)
- `Mesh.Y` - координаты по оси Y (1 × Ny)
- `offset(off)` - сдвиг сетки на вектор `off`
- `size()` - размеры сетки

**Пример:**
```matlab
% Сетка 512×512 с размером пикселя 4 микрона
mesh = Mesh(4e-6, 512);

% Сетка 2048×512 с разными размерами пикселей
mesh = Mesh([2e-6, 4e-6], [2048, 512]);
```

#### `InputModulator` - Модулятор входного поля
**Назначение:** Начальный слой, который преобразует входные данные в оптическое поле.

**Параметры:**
- `Mesh` - сетка входного слоя
- `Func` - функция преобразования входных данных (опционально)

**Методы:**
- `get_field(input)` - применить функцию к входу

**Пример:**
```matlab
% Входной модулятор с нормализацией поля
dc = InputModulator(mesh_inp, @(W)normalize_field(W));

% Входной модулятор с квази-когерентным источником
AMP = exp(-(mesh_inp.X.^2 + mesh_inp.Y.^2)./(0.5*mesh_inp.X(end)).^2);
dc = InputModulator(mesh_inp, @(W)normalize_field(AMP.*exp(2i*pi*rand(...))));
```

---

### Распространение волн

Все распространители (Propagators) реализу��т физику распространения электромагнитного поля.

#### `SincPropagator` - Sinc-интерполяционное распространение
**Назначение:** Точное распространение волны на расстояние `distance` в свободном пространстве.

**Параметры:**
- `prev` - предыдущий слой
- `distance` - расстояние распространения (в метрах)
- `wavelength` - длина волны света (в метрах)

**Особенности:**
- Использует sinc-интерполяцию для высокой точности
- Может изменять размер сетки
- Медленнее чем ASMPropagator, но более точен для малых расстояний

**Пример:**
```matlab
lambda = 532e-9;  % зелёный свет
f = 0.01;         % расстояние 1 см

dc = InputModulator(mesh_inp, @(W)normalize_field(W));
dc = SincPropagator(dc, f, lambda);
dc = FullDOE(dc, mesh, PhaseDOE(), AdamFabric());
dc = SincPropagator(dc, f, lambda);
```

#### `ASMPropagator` - Angular Spectrum Method
**Назначение:** Быстрое распространение волны через Фурье-преобразование.

**Параметры:**
- `prev` - предыдущий слой
- `distance` - расстояние распространения
- `wavelength` - длина волны

**Особенности:**
- Очень быстрый благодаря FFT
- Сохраняет размер сетки
- Идеален для больших расстояний

**Пример:**
```matlab
dc = SincPropagator(dc, f, lambda);
dc = ASMPropagator(dc, f, lambda);
dc = FullDOE(dc, mesh, PhaseDOE(), opt);
dc = ASMPropagator(dc, f, lambda);
```

#### `CompiledMatrixPropagator` - Композитный распространитель
**Назначение:** Объединяет несколько распространителей в одну матричную операцию для ускорения.

**Методы:**
- `add_next(propagator)` - добавить слой в цепь

**Пример:**
```matlab
% 4F-система с цилиндрическими линзами
dc = CompiledMatrixPropagator(dc);
dc.add_next(SincPropagator(dc, f, lambda));
dc.add_next(CylindricalDOE(dc, mesh_lens, PhaseDOE(), "X")...
  .set_data(-2*pi/lambda/f/2*mesh_lens.X.^2));
dc.add_next(CylindricalDOE(dc, mesh_lens, PhaseDOE(), "Y")...
  .set_data(-2*pi/lambda/f/2*mesh_lens.Y.^2));
dc.add_next(SincPropagator(dc, f, lambda));
```

---

### Дифракционные элементы (DOE)

Дифракционные оптические элементы (DOE) - обучаемые слои нейронной сети.

#### `DOE` - Базовый класс (абстрактный)
**Назначение:** Определяет интерфейс для всех дифракционных элементов.

**Абстрактные методы:**
- `get_transmission_function()` - передаточная функция элемента
- `is_trainable()` - является ли слой обучаемым
- `get_gradient(error)` - вычисление градиента
- `make_gradient_step(gradient, speed)` - обновление параметров

#### `FullDOE` - Полностью обучаемый дифракционный элемент
**Назначение:** Основной слой нейронной сети, все параметры которого обучаются.

**Параметры:**
- `prev` - предыдущий слой
- `Mesh` - сетка элемента
- `type` - тип DOE (`PhaseDOE`, `AmplitudeDOE`, и т.д.)
- `optimizer_fabric` - фабрика оптимизатора (опционально)

**Методы:**
- `set_data(data)` - установить начальные параметры
- `set_mask(mask)` - установить маску обучаемости (0 = не обучать, 1 = обучать)
- `imagesc()` - визуализировать параметры элемента

**Пример:**
```matlab
% Создать обучаемый фазовый дифракционный элемент
opt = AdamFabric();
doe = FullDOE(dc, mesh, PhaseDOE(), opt);

% С маской: обучать только центральную часть
mask = zeros(size(mesh));
mask(100:400, 100:400) = 1;
doe.set_mask(mask);

% Начальные значения: линза
phase_init = -2*pi/lambda/f/2*(mesh.X.^2 + mesh.Y.^2);
doe.set_data(phase_init);
```

#### `PhaseDOE` - Фазовый дифракционный элемент
**Назначение:** Элемент, который модулирует только фазу волны.

**Передаточная функция:** `T = exp(i * data)`

**Пример использования:**
```matlab
dc = FullDOE(dc, mesh, PhaseDOE(), AdamFabric());
```

#### `AmplitudeDOE` - Амплитудный дифракционный элемент
**Назначение:** Элемент, который модулирует амплитуду волны.

**Передаточная функция:** `T = data` (обычно вещественные значения [0, 1])

#### `CylindricalDOE` - Цилиндрический дифракционный элемент
**Назначение:** Разделяемый элемент, действующий независимо на X или Y координату. Используется для реализации цилиндрических линз.

**Параметры:**
- `direction` - направление ("X" или "Y")

**Пример:**
```matlab
% Реализовать цилиндрическую линзу с фокусным расстоянием f
cx_lens = CylindricalDOE(dc, mesh, PhaseDOE(), "X")...
  .set_data(-2*pi/lambda/f/2*mesh.X.^2);
```

---

### Выходные слои

Слои, которые преобразуют поле в результаты классификации/генерации.

#### `GetFullIntensity` - Полная интенсивность поля
**Назначение:** Вычислить интенсивность |поле|² на выходе системы.

**Пример:**
```matlab
dc = SincPropagator(dc, f, lambda);
dc = GetFullIntensity(dc, mesh);
```

#### `GetMaskSum` - Интенсивность в маске
**Назначение:** Вычислить сумму интенсивности в заданной маске, используется для выделения информации с детектора.

**Параметры:**
- `mask` - бинарная маска области интереса

**Пример:**
```matlab
% Маска для 10 квадратных детекторов
MASK = mask10_1(mesh, [1.2e-3, 0.9e-3], 100e-6);
dc = GetMaskSum(dc, mesh, MASK);
```

#### `NormalizationMAX` - Нормализация через максимум
**Назначение:** Нормализует выходы, деля каждый на максимум. Используется для классификации.

**Пример:**
```matlab
dc = GetMaskSum(dc, mesh, MASK);
predictor = NormalizationMAX(dc);
```

#### `NormalizationSUM` - Нормализация через сумму
**Назначение:** Нормализует выходы как вероятностное распределение (сумма = 1).

**Пример:**
```matlab
dc = GetOutput(dc, mesh);
dc = NormalizationSUM(dc);
```

#### `ScoreSpliter` - Разделитель оценок
**Назначение:** Разделяет выходное поле на отдельные оценки для классов.

**Пример:**
```matlab
dc = GetMaskSum(dc, mesh, MASK);
dc = ScoreSpliter(dc);  % Разделить по 10 выходам
```

---

### Функции ошибок

#### `ErrorFunction` - Базовый класс для функций ошибок

#### `ErrorSCE` - Softmax Cross-Entropy (категориальная кросс-энтропия)
**Назначение:** Стандартная функция ошибок для классификации.

**Параметры:**
- `predictor` - предсказывающий слой
- `target` - целевой слой
- `batch_size` - размер батча

**Пример:**
```matlab
target = ClassificationTarget(10, 10);  % 10 классов
err = ErrorSCE(predictor, target, 20);
```

#### `ErrorMSE` - Mean Squared Error
**Назначение:** Среднеквадратическая ошибка, используется для регрессии и генерации.

**Пример:**
```matlab
target = GenerationTarget(Target);
Error = ErrorMSE(dc, target);
```

#### `ErrorPEF` - Phase Equilibrium Function
**Назначение:** Штраф за нефизичные значения параметров (например, фаза вне [-π, π]).

**Пример:**
```matlab
err1 = ErrorSCE(predictor, ClassificationTarget(...), 20);
err2 = ErrorPEF(dc);
Error = ErrorSUM(err1, 0.9).add_new(err2, 0.1);  % Комбинированная ошибка
```

#### `ErrorSUM` - Сумма ошибок с весами
**Назначение:** Комбинировать несколько функций ошибок с коэффициентами.

**Пример:**
```matlab
Error = ErrorSUM(err1, 0.9).add_new(err2, 0.1);
Error = Error.add_new(err3, 0.05);
```

---

### Оптимизаторы

#### `OptimizerFabric` - Базовый класс для фабрик оптимизаторов
**Назначение:** Создавать оптимизаторы для слоев сети.

#### `AdamFabric` - Фабрика оптимизатора Adam
**Назначение:** Создаёт адаптивные оптимизаторы Adam для каждого слоя.

**Особенности:**
- Адаптивная скорость обучения
- Хорошо работает по умолчанию
- Рекомендуется для большинства задач

**Пример:**
```matlab
opt = AdamFabric();
doe = FullDOE(dc, mesh, PhaseDOE(), opt);
```

#### `SGDFabric` - Стохастический градиентный спуск
**Особенности:**
- Простой и быстрый
- Требует тщательной настройки скорости обучения

#### `AdagradFabric` - Adagrad оптимизатор
**Особенности:**
- Хорошо работает для разреженных градиентов

#### `NesterovFabric` - Nesterov Momentum оптимизатор
**Особенности:**
- Ускоренный градиентный спуск
- Часто быстрее сходится

#### `RMSpropFabric` - RMSprop оптимизатор
**Особенности:**
- Адаптивная скорость обучения
- Хорошо для рекуррентных сетей

---

## Примеры использования

Все примеры находятся в `script_ex.m`. Ниже описаны основные сценарии:

### Пример 1: Классификация MNIST с одним DOE

```matlab
clear variables;

% Параметры
lambda = 632.8e-9;      % красный лазер
f = 0.01;               % расстояние 1 см
mesh = Mesh(4e-6, 512); % выходная сетка
mesh_inp = Mesh(8e-6, 28);  % входная сетка (28×28 MNIST)

% Загрузить данные MNIST
mnist_digits;  % Загружает Train, TrainLabel

% Построить систему
opt = AdamFabric();
dc = InputModulator(mesh_inp, @(W)normalize_field(W));
dc = SincPropagator(dc, f, lambda);
dc = FullDOE(dc, mesh, PhaseDOE(), opt); doe = dc;
dc = ASMPropagator(dc, f, lambda);

% Маска с 10 детекторами
MASK = mask10_1(mesh, [1.2e-3, 0.9e-3], 100e-6);
dc = GetMaskSum(dc, mesh, MASK);
decoder = dc;

% Выходные слои
dc = ScoreSpliter(dc);
predictor = NormalizationMAX(dc);

% Функция ошибки
err1 = ErrorSCE(predictor, ClassificationTarget(10, 10), 20);
err2 = ErrorPEF(dc);
Error = ErrorSUM(err1, 0.9).add_new(err2, 0.1);

% Параметры обучения
epoch = 4;
batch = 20;
cycle = 6000;
speed = 0.3;
slowdown = 0.9995;

% Запустить обучение (см. training1.m)
training1;

% Проверить результаты
check_result;
```

### Пример 2: 4F-система с линзами

```matlab
% 4F система для оптической обработки информации
lambda = 532e-9;
f = 0.25;

mesh_doe = Mesh(16e-6, 512);     % Основной DO
mesh_lens = Mesh(3e-6, 4096);    % Линзы
mesh_inp = Mesh(36e-6, 28);

% Входной слой
dc = InputModulator(mesh_inp, @(W)normalize_field(W));

% Первый пропагатор и линзы
dc = CompiledMatrixPropagator(dc);
dc.add_next(SincPropagator(dc, f, lambda));
dc.add_next(CylindricalDOE(dc, mesh_lens, PhaseDOE(), "X")...
  .set_data(-2*pi/lambda/f/2*mesh_lens.X.^2));
dc.add_next(CylindricalDOE(dc, mesh_lens, PhaseDOE(), "Y")...
  .set_data(-2*pi/lambda/f/2*mesh_lens.Y.^2));
dc.add_next(SincPropagator(dc, f, lambda));

% Обучаемый дифракционный элемент
dc = FullDOE(dc, mesh_doe, PhaseDOE(), AdamFabric()); doe = dc;

% Второй пропагатор и линзы
dc = CompiledMatrixPropagator(dc);
dc.add_next(SincPropagator(dc, f, lambda));
dc.add_next(CylindricalDOE(dc, mesh_lens, PhaseDOE(), "X")...
  .set_data(-2*pi/lambda/f/2*mesh_lens.X.^2));
dc.add_next(CylindricalDOE(dc, mesh_lens, PhaseDOE(), "Y")...
  .set_data(-2*pi/lambda/f/2*mesh_lens.Y.^2));
dc.add_next(SincPropagator(dc, f, lambda));

% Декодер
MASK = mask10_1(mesh_doe, [5e-3, 4e-3], 1e-3);
dc = GetMaskSum(dc, mesh_doe, MASK);
decoder = dc;
dc = NormalizationSUM(dc);
Error = ErrorSCE(dc, ClassificationTarget(10, 10), 80);
predictor = Error;

% Обучение
epoch = 4;
batch = 20;
cycle = 6000;
speed = 0.3;
slowdown = 0.9995;
training1;
```

### Пример 3: Генерация изображений

```matlab
% Синтез оптических изображений
clear variables;
global is_gpu; is_gpu = true;

f = 0.15;
lambda = 532e-9;
k = 2*pi/lambda;
mesh = Mesh(18e-6, 512);

% Входные волны (наклонные плоские волны)
B = 18e-6*512/2;
sigma = B/8;
alpha = pi/180/10;

Amp = normalize_field(exp(-(mesh.X.^2 + mesh.Y.^2)/2/sigma^2));
Train(:,:,1) = Amp.*exp( 1i*k*sin(alpha)*mesh.X);
Train(:,:,2) = Amp.*exp(-1i*k*sin(alpha)*mesh.X);
Train(:,:,3) = Amp.*exp( 1i*k*sin(alpha)*mesh.Y);
Train(:,:,4) = Amp.*exp(-1i*k*sin(alpha)*mesh.Y);
TrainLabel = 1:size(Train,3);

% Целевые изображения
Target(:,:,1) = ((mesh.X.^2 + mesh.Y.^2) < (B/4)^2).*...
               ((mesh.X.^2 + mesh.Y.^2) > (B/4.4)^2);  % кольцо
Target(:,:,2) = (max(abs(mesh.X), abs(mesh.Y)) < B/4).*...
               (max(abs(mesh.X), abs(mesh.Y)) > B/4.4);  % квадрат
Target(:,:,3) = (max(abs(mesh.X), abs(mesh.Y)) < B/4).*...
               (min(abs(mesh.X), abs(mesh.Y)) < B*0.05/4.4);  % крест
Target(:,:,4) = (max(abs(mesh.X), abs(mesh.Y)) < B/4).*...
               (abs(abs(mesh.X) - abs(mesh.Y)) < B*0.07/4.4);  % X
Target = normalize_field(Target).^2;

% Система с тремя DOE
dc = InputModulator(mesh);
dc = ASMPropagator(dc, f, lambda);
dc = FullDOE(dc, mesh, PhaseDOE(), AdamFabric());
dc = ASMPropagator(dc, f, lambda);
dc = FullDOE(dc, mesh, PhaseDOE(), AdamFabric());
dc = ASMPropagator(dc, f, lambda);
dc = FullDOE(dc, mesh, PhaseDOE(), AdamFabric());
dc = ASMPropagator(dc, f, lambda);
dc = GetFullIntensity(dc, mesh);

% MSE ошибка
Error = ErrorMSE(dc, GenerationTarget(Target));

% Обучение
batch = size(Train,3);
epoch = batch*2000;
cycle = epoch*batch/10;
speed = 1;
slowdown = 0.9992;
training1;

% Визуализация результатов
for iter=1:size(Train,3)
    figure;
    imagesc(dc.intensity(Train(:,:,iter)));
    title(['Generated pattern ', num2str(iter)]);
end
```

---

## Построение оптических систем

### Общая схема построения

```matlab
% 1. Определить координатные сетки
mesh_input = Mesh(pixel_size, resolution);
mesh_doe = Mesh(doe_pixel, doe_resolution);

% 2. Создать входной модулятор
dc = InputModulator(mesh_input, transformation_func);

% 3. Добавить распространители и DOE (чередуя)
dc = SincPropagator(dc, distance, wavelength);
dc = FullDOE(dc, mesh_doe, PhaseDOE(), optimizer);
dc = ASMPropagator(dc, distance, wavelength);

% 4. Добавить выходной слой
dc = GetMaskSum(dc, mesh_doe, mask);

% 5. Добавить нормализацию и предсказатель
dc = NormalizationMAX(dc);

% 6. Определить функцию ошибки
Error = ErrorSCE(dc, ClassificationTarget(...), batch_size);

% 7. Обучить (см. training1.m)
training1;
```

### Типовые конфигурации

**Конфигурация 1: Простая система (1 слой)**
```
Input → SincPropagator → FullDOE → GetMaskSum → Output
```

**Конфигурация 2: Двухслойная система**
```
Input → SincPropagator → FullDOE → ASMPropagator → FullDOE → GetMaskSum → Output
```

**Конфигурация 3: 4F-система**
```
Input → SincProp → CylDOE(X) → CylDOE(Y) → SincProp → FullDOE 
      → SincProp → CylDOE(X) → CylDOE(Y) → SincProp → GetMaskSum → Output
```

**Конфигурация 4: Генеративная система**
```
Input → ASM → FullDOE → ASM → FullDOE → ... → GetFullIntensity → Output
```

### Советы по проектированию

1. **Выбор распространителя:**
   - Малые расстояния (< λ/100): используйте `SincPropagator`
   - Большие расстояния: используйте `ASMPropagator`
   - Много слоев: используйте `CompiledMatrixPropagator`

2. **Размер сетки:**
   - Большая сетка = лучшая точность, медленнее
   - Малая сетка = быстрее, потеря информации
   - Типичные размеры: 512×512, 1024×1024, 2048×2048

3. **Маски для DOE:**
   - Ограничить обучаемый регион маской для физических систем
   - Маска = 1 означает обучать, маска = 0 означает не обучать

4. **Функции ошибок:**
   - Классификация: `ErrorSCE`
   - Регрессия: `ErrorMSE`
   - Комбинировать через `ErrorSUM`

5. **Оптимизаторы:**
   - Начните с `AdamFabric()` - хороший выбор по умолчанию
   - Если не сходится - попробуйте `NesterovFabric`
   - Для специальных задач - `RMSpropFabric`

---

## Структура проекта

```
DNN/
├── utils/
│   ├── Prop/                      # Распространители и основные компоненты
│   │   ├── Mesh.m                 # Координатная сетка
│   │   ├── InputModulator.m        # Входной модулятор
│   │   ├── Encoder.m              # Базовый класс для входных слоев
│   │   ├── Decoder.m              # Базовый класс для выходных слоев
│   │   ├── Predictor.m            # Интерфейс для предсказания
│   │   ├── Prop.m                 # Базовый класс для всех слоев
│   │   ├── does/                  # Дифракционные элементы
│   │   │   ├── DOE.m              # Базовый класс DOE
│   │   │   ├── FullDOE.m          # Полностью обучаемый DOE
│   │   │   ├── PhaseDOE.m         # Фазовый модулятор
│   │   │   ├── AmplitudeDOE.m     # Амплитудный модулятор
│   │   │   ├── CylindricalDOE.m   # Цилиндрический DOE
│   │   │   └── TypeDOE.m          # Интерфейс типов DOE
│   │   ├── free_propogators/       # Распространители в свободном пространстве
│   │   │   ├── FreePropagator.m    # Базовый класс
│   │   │   ├── SincPropagator.m    # Sinc-интерполяция
│   │   │   └── ASMPropagator.m     # Angular Spectrum Method
│   │   └── output/                 # Выходные слои
│   │       ├── GetOutput.m         # Базовый выходной слой
│   │       ├── GetMaskSum.m        # Сумма в маске
│   │       ├── GetFullIntensity.m  # Полная интенсивность
│   │       ├── NormalizationMAX.m  # Нормализация через макс
│   │       ├── NormalizationSUM.m  # Нормализация через сумму
│   │       └── ScoreSpliter.m      # Разделитель оценок
│   ├── Error/                      # Функции ошибок
│   │   ├── ErrorFunction.m         # Базовый класс
│   │   ├── ErrorSCE.m             # Softmax Cross-Entropy
│   │   ├── ErrorMSE.m             # Mean Squared Error
│   │   ├── ErrorMAE.m             # Mean Absolute Error
│   │   ├── ErrorPEF.m             # Phase Equilibrium Function
│   │   ├── ErrorSUM.m             # Комбинированная ошибка
│   │   └── Error_Decoder.m        # Вспомогательный класс
│   ├── Target/                     # Целевые значения
│   │   ├── GetTarget.m             # Базовый класс
│   │   ├── ClassificationTarget.m  # Для классификации
│   │   └── GenerationTarget.m      # Для генерации
│   ├── optimizer/                  # Оптимизаторы
│   │   ├── Optimizer.m             # Базовый класс
│   │   ├── SGDOptimizer.m          # SGD
│   │   ├── AdamOptimizer.m         # Adam
│   │   ├── AdagradOptimizer.m      # Adagrad
│   │   ├── NesterovOptimizer.m     # Nesterov Momentum
│   │   ├── RMSpropOptimizer.m      # RMSprop
│   │   └── Fabrics/                # Фабрики оптимизаторов
│   │       ├── OptimizerFabric.m
│   │       ├── SGDFabric.m
│   │       ├── AdamFabric.m
│   │       ├── AdagradFabric.m
│   │       ├── NesterovFabric.m
│   │       └── RMSpropFabric.m
│   ├── normalize_field.m           # Нормализация поля
│   ├── TrackControl.m              # Отслеживание обучения
│   ├── fresnelC.m, fresnelS.m      # Интегралы Френеля
│   └── ...                         # Вспомогательные функции
├── script_ex.m                     # Примеры (ЗАПУСТИТЬ ЭТО!)
├── training1.m                     # Цикл обучения
├── check_result.m                  # Проверка результатов
├── check_offsets.m                 # Проверка смещений
└── README.md                       # Этот файл
```

---

## Параметры обучения

Основные параметры в `training1.m`:

```matlab
epoch = 4;          % Количество эпох
batch = 20;         % Размер батча
cycle = 6000;       % Итерации в цикле
speed = 0.3;        % Начальная скорость обучения
slowdown = 0.9995;  % Коэффициент снижения скорости (каждая итерация)
```

**Рекомендации:**
- Начните с `speed = 0.1` и увеличивайте по необходимости
- `slowdown` близко к 1 означает медленное снижение скорости
- Увеличение `epoch` улучшает точность, но медленнее

---

## Быстрая справка по строительству системы

```matlab
% Инициализация
global is_gpu; is_gpu = true;
addpath(genpath(pwd));

% Параметры
lambda = 532e-9;
f = 0.01;
mesh = Mesh(4e-6, 512);

% Система
dc = InputModulator(mesh_in, @normalize_field);
dc = SincPropagator(dc, f, lambda);
dc = FullDOE(dc, mesh, PhaseDOE(), AdamFabric());
dc = ASMPropagator(dc, f, lambda);
dc = GetMaskSum(dc, mesh, MASK);
dc = NormalizationMAX(dc);

% Ошибка и обучение
Error = ErrorSCE(dc, ClassificationTarget(10, 10), 20);
speed = 0.3;
training1;
```

---

## Ссылки

- Sinc интерполяция: Cubillos, M. Numerical simulation of optical propagation using sinc approximation // Journal of the Optical Society of America A. - 2022. - Vol. 39, Issue 8. - P. 1403-1413.

---

**Автор:** androidZ200  
**Лицензия:** -  
**Последнее обновление:** 2026
