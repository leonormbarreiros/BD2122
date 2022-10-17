/*num dado período (i.e. entre duas datas), por dia da semana, por concelho e no total*/

SELECT dia_semana, concelho, SUM (unidades)
FROM Vendas
WHERE ano>1998 and ano<=2021
GROUP BY CUBE(dia_semana, concelho);


/*2. num dado distrito (i.e. “Lisboa”), por concelho, categoria, dia da semana e no total*/

SELECT concelho, cat, dia_semana, SUM (unidades)
FROM Vendas
WHERE distrito='Setubal'
GROUP BY GROUPING SETS ((concelho, cat, dia_semana), (concelho), (cat), (dia_semana), ());