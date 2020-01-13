# Décimo tercera semana, comienza el 8-13 de enero

En la primera semana del año se resolverán en la clase de prácticas
dudas sobre la entrega de los hitos 4 y 5 y otros hitos que queden pendientes.

## Objetivos de la asignatura

1. Entender los conceptos medición de prestaciones
2. Entender los conceptos detrás del provisionamiento de una máquina virtual o contenedor.
3. Entender las diferentes fases de despliegue de una aplicación.

## Objetivos adicionales

1. Recomendaciones:
   1. [Script para Taurus de carlos-el](https://github.com/carlos-el/EventPost-CCProject/blob/master/tests/performance/performance_testing.yml).
   2. [Inyección de dependencias de alvarillo89](https://github.com/alvarillo89/UGR-CC-Project/blob/master/docs/mongo.md).
1. (Jueves 9 de enero) Entender los errores del hito 4.
   1. Las llamadas en un API REST no son subrutinas o funciones, son métodos de un objeto que tiene que estar explícitamente referido en la ruta. No se hace newObjeto, se hace PUT objeto, no se hace searchObjeto sino objeto/search. Todas las rutas son métodos de un objeto principal que se representa mediante la raíz de una ruta. Eso permite que, se creen métodos específicos por ruta, o incluso que desde un API gateway se usen diferentes servicios para diferentes rutas. 
   1. Un API REST tampoco es una forma de invocar un programa. Si quieres acceder a los datos mediante un API REST, pues se accede, pero si es un programa normal, simplemente se llama a ese programa.
   2. En este hito se trataba de hacer mejoras para conseguir el grado de prestaciones adecuado.
	   1. Se debe mantener el diseño de la clase, usando si acaso inyección de dependencias (lo que se puntúa). No se puede "tirar la clase" y acceder directamente a la BD (entre otras cosas no va a haber mucha mejora).
	   2. Se debería enlazar el issue o commits que se hayan usado para esos cambios, de forma que se vea que se han hecho efectivamente. Si no, se ve sólo el resultado final.
	   3. Se olvida totalmente el hito antrior, donde se probaban diferentes imágenes base. Nadie usa diferentes imágenes base para mejorar las prestaciones.
	   4. Dependiendo del escenario, usar una caché es más bien trampa. Si simplemente haces peticiones a los URLs que ya están en la caché, realmente no estás mejorando nada "en el mundo real". Tu escenario debe incluir una cantidad aceptable de peticiones que no estén en la caché.
   3. (Casi) nadie configura acceso a datos con inversión de dependencias.
3. Probar diferentes sistemas de aprovisionamiento, especialmente Ansible y Chef.
4. Entender la *galaxia* de Ansible y en qué nos puede ayudar.

## Material para esta semana

Se terminan los objetivos
del
[tema sobre aprovisionamiento](http://jj.github.io/CC/documentos/temas/Provision.html) y 
se va preparando la entrega del [hito final](http://jj.github.io/CC/documentos/proyecto/5.Provisionamiento) el próximo domingo **19 de enero**.


## Siguiente semana

[Semana 14](14-semana.md)
