/* a) Qual o nome do retalhista (ou retalhistas) responsáveis 
pela reposição do maior número de categorias? */

SELECT name
FROM retalhista NATURAL JOIN responsavel_por
GROUP BY name
HAVING COUNT(nome_cat) >= ALL
	(SELECT COUNT(nome_cat)
	FROM retalhista NATURAL JOIN responsavel_por
		GROUP BY name);

----------------------------

/* b) Qual o nome do ou dos retalhistas que sao responsaveis 
por todas as categorias simples? */

-- Projetar o nome dos retalhistas
SELECT R.name
FROM (
    -- Obter todos os retalhistas que correspondem 
    SELECT *
    FROM retalhista
    -- A chave do retalhista tem de ser igual a chave de todos...
    WHERE tin = ALL (
        SELECT Q.tin
        FROM (
            -- ... os responsaveis por uma categoria simples
            SELECT *
            FROM responsavel_por
            WHERE nome_cat IN (
                SELECT nome FROM categoria_simples
            )
        ) AS Q
    )
) AS R;

----------------------------

/* c) Quais os produtos (ean) que nunca foram repostos? */

select ean from produto where ean not in (select ean from evento_reposicao);

----------------------------

/* d) Quais os produtos (ean) que foram repostos sempre pelo mesmo retalhista? */

select ean from evento_reposicao group by ean having count(distinct tin) = 1;
