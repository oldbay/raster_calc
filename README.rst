=====================
Растровый калькулятор
=====================

Зависимости:
------------

* numpy
* raster_tools (https://github.com/oldbay/raster_tools)

Установка:
----------
Для установки при помощи pip:
    pip install git+https://github.com/oldbay/raster_calc

Для установки в gentoo linux:
    представлен ebuild сценарий raster-calc-999.ebuild


Инструментарий представлен:
---------------------------
Утилитой:
~~~~~~~~~
    *raster_calc*- растровый калькулятор который может производить нормализацию комплектов исходных геоданных, радиологическую и атмосферную коррекцию
                                                                                               
применение:
~~~~~~~~~~~
    raster_calc <метод расчёта> <путь до конфига расчёта> <путь/до/конф/файла>

где:
    <метод расчёта> - сейчас имеются в наличии:
                    * landsat - нормализация исходных геоданных landat 5,7,8
                    * ndvi - вегетативный индекс
                    * ndwi - водный индекс
                    * (можно добавить свой метод через конфиг)

    <путь до конфига расчёта>: 
                     для landsat - путь до \*_MTL.txt
                     для индексов - путь до любого файла в каталоге


Пример нормализации L1 ДДЗ landsat
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*raster_calc lansat <путь>/<имя>.MTL.txt*

Файл радиологической коррекции должен располагаться в одном каталоге с 
георастрами (как он располагается в архиве от USGS)
В результате работы скрипта в каталоге с \*_MTL.txt будут созданы
нормализованные спектральные растры(при дефолтном конфиге):

    * blue.tif - для синего канала
    * green.tif - для зелёного канала
    * red.tif - для красного канала
    * nir.tif - для ближнего ИК канала
    * swir1.tif - для среднего ИК1 канала
    * swir2.tif - для среднего ИК2 канала

Эти же названия спектральных растров используется для расчёта
индексов.


Подключение дополнительных модулей
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Подключение дополнительных модулей калькулятора к утилите производится через модификацию основного конфигурационного файла калькулятора.

Пример такой модификации(NDVI):

.. code:: python

    import importlib

    # Добавить в словарь имя(имена) метода(ов) и импортировать модуль нового метода 
    # по путям файловой системы при помощи importlib
    calc_methods = {
        "ndvi": importlib.import_module("ndvi_module"),
    }

Другие переменные для модификации - можно увидеть в *raster_calc/config.py*:
новые ключи переменных в формате словаря дополняются,
существующие ключи - заменяются,
остальные типы переменных заменяются полностью.

В подключаемом дополнительном модуле калькулятора необходимо наличие функции **calc** принимающей в качестве аргумента
второй аргумент командной строки утилиты *raster_calc* - *<путь до конфига расчёта>*.

Пример модуля (NDVI):

.. code:: python

    import os, sys
    import numpy as np
    from raster_tools import raster2array, array2raster

    def calc(_file):
        
        # получение пути к каталогу со спектральными растрами
        path = os.path.dirname(_file)

        # присвоение растра красного канала объекту raster_tools.raster2array в качестве метаданных
        METADATA = raster2array("%s/red.tif"%path)
        
        # получение numpy массива для красного канала из объекта raster_tools.raster2array 
        RED = METADATA()
        
        # получение numpy массива для ближнего ИК канала из объекта raster_tools.raster2array 
        NIR = raster2array("%s/nir.tif"%path)()
        
        # расчёт вегетативного индекса
        ndvi = (NIR - RED) / (NIR + RED)
        
        # сохранение вегетативного индекса в виде растра
        array2raster(METADATA, ndvi, path+"/index_ndvi.tif")

Пример подключаемого модуля в examples:
```````````````````````````````````````
*examples/example_add_index/sarvi_index.py* - пример стороннего модуля калькулятора для рассчёта вегетативного индекса SARVI

Данный пример сопровождается примером конфигурационного файла:
    *examples/example_add_index/config.py* - подключающего данный модуль к утилите

Применение подключаемого модуля:
````````````````````````````````
Подключать конфигурационный файл дополнительного модуля можно двумя способами:

через системную пересенную:
    *env RASTER_CALC_CONF=config.py raster_calc sarvi <путь до спектрального растра>*

через аргумент командной строки:
    *raster_calc sarvi <путь до спектрального растра> config.py*


Примеры применение калькулятора в коде (без использования утилиты)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*examples/example_calc_more_indexes.py* - простой вариант написания растрового калькулятора, для расчёта NDVI, NDWI, транспирационной маски и TNDVI. 

Скрипт позволяет применять простые математические вычисления к операциям с одинаково спозицианированными георастрами.

Для работы скрипта требуется каталог со спектральными растрами.

Результат работы примера:
`````````````````````````
*calc_index_example.py <каталог со спектральными растрами>*

В результате работы скрипта в каталоге со спектральными растрами
будут созданы растры индексов:

* index_ndvi_standart.tif - NDVI стандартный метод расчёта
* index_ndvi.tif - NDVI с фильтром
* index_ndwi_standart.tif - NDWI стандартный метод расчёта
* index_ndwi.tif - NDWI с фильтром
* index_tndvi.tif - транспирационный NDVI
