# Undécima semana, 19 de diciembre

Hacemos las explicaciones en un seminario extraordinario el martes día 10 a las 12:30 de la mañana en la -1.2.

## Objetivos de la asignatura

* Tener listos diferentes sistemas cloud donde se puedan desplegar máquinas
  virtuales.

* Conocer diferentes lugares donde haya imágenes de sistemas
  operativos listas para usar.

* Instalar y configurar diferentes sistemas de provisionamiento.

* Entender los conceptos de los sistemas de máquinas virtuales y cómo
  configurarlos desde línea de órdenes.
* Entender las nociones básicas de seguridad.

## Objetivos adicionales

1. Entender los errores de la entrega del hito 3.
   * El README.md es del proyecto que estáis haciendo, con enlaces adicionales (y precisos) para corregir. Por favor, entenderlo así.
   * No quiero ni un loquesea login más, por favor.
   * Hacer benchmarks cuantitativos está bien, hacerlos bien y de forma precisa está mejor.
	 * No basta bajarse un URL n veces, sino que hay que seguir una secuencia de POST/GET delete simultánea de varios clientes a la vez. En [este ejemplo](https://gist.github.com/kelvinn/6a1c51b8976acf25bd78) explica como hacerlo.
	 * Si los resultados son sorprendentes, hay que revisar el proyecto. Por ejemplo, un programa debería dar cientos o incluso [ miles de peticiones al segundo](https://wrongsideofmemphis.com/2013/10/21/requests-per-second-a-reference/).
	 * No sé de donde habéis sacado lo de 10 y 1000, pero debéis entender lo que hacéis. Por ejemplo, si tenéis sólo una copia del servidor, no debéis lanzar 10 peticiones a la vez porque lo sobrecargáis. Usad un número de peticiones simultáneas y servidores similares.
	 * Prácticamente nadie crea usuarios dentro del contenedor. Aunque no es imprescincible, es una buena práctica que conviene seguir.
	* Los commits deben siempre, salvo en casos excepcionales, referirse a un issue. Los issues no están para cerrarlos y pasar el test. 
1. Instalarse los diferentes clientes de líneas de órdenes de los
   sistemas en la nube a los que se tenga acceso.

## Material para la clase

## Material para esta semana

* *Teoría*: Comenzamos
  el
  [tercer tema](http://jj.github.io/CC/documentos/temas/Automatizando_cloud)

* El cuarto hito se entregará el *12 de diciembre*
