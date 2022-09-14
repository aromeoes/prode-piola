# prode-piola

## Info

Esto es un recontra beta, consideraciones:

- Temporalmente quien tiene la capacidad de "Oraculo" y reportar resultados de partidos, es quien deployea el contrato (variable "owner")
  > _Consideraciones de Oraculos:_ Esto se tiene que mejorar reemplazando owner por un consumo de Chainlink con mediante external provider de resultados del mundial. No encontré en Chainlink esta data (deporte si, pero para muy pocas cosas, nada de mundial). Tampoco encontré una API oficial de FIFA, o de un ente reputable para integrar mediante "connect your OWN API". También se podría cambiar del Owner como oráculo, a un conjunto multisig. Por el momento me pareció good enough para un MVP.
-El array fixture para simplificar el testeo solo tiene 3 elementos. Cada partido con una predicción debería agregarse ahí (por ejemplo a1, a2, y a3 están pensados como los primeros 3 partidos del grupo A)
-Los devs se llevan 0%
-El contrato actual espera un stake de 5000 WEI
-La idea es que haya un 2do contrato que sea un creador de prodes, y que el prode sea cerrado, y el creador whitelistee las addresses de sus amigos. Yo creo que la joda del producto es que sea social y de grupo cerrado, no algo abierto. Esto también anula la posibilidad de que el oraculo participe de un torneo, y tenga el incentivo de reportar resultados incorrectos para robarse la guita.
> Quizas es una buena idea agregar un panic button, que si un 60% de los participantes lo apretaron el torneo se da de baja, y se devuelve toda la guita
-El inicio del mundial lo marca el Owner. La version final debería tener un timestamp con la fecha

## Como funciona
1. Deployas el contrato
2. Participantes ejecutan la función **createParticipant**, garpando 5000 WEI, y dando un array con todas sus predicciones (ejemplo: ["1-0","2-0","0-0"])
3. Cuando el torneo arranca (en esta fase) se debe correr la funcion **temporaryCupBegins**, esto pasa el estado del torneo a **durante** e impide nuevos participantes
4. A medida que vayan sucediendo los partidos, el Oraculo debe correr la funcion **OracleUpdate** actualizando el resultado final de cada partido a medida que suceden.
5. Una vez finalizado el mundial el Oraculo corre la funcion **oracleEnd**, y se reparte el pool