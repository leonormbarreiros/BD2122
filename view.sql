/*  Colocar o codigo como uma query normal e correr. 
    No menu do pgAdmin, onde se veem as tables ha uma option para as views que deve ter la a view gerada*/
DROP VIEW IF EXISTS Vendas;

CREATE VIEW Vendas(ean, cat, ano, trimestre, mes, dia_mes, dia_semana, distrito, concelho, unidades)
AS(
	SELECT produto.ean AS ean, 
		categoria.nome AS cat, 
		EXTRACT(YEAR FROM evento_reposicao.instante) AS ano, 
		EXTRACT(QUARTER FROM evento_reposicao.instante) AS trimestre,
		EXTRACT(MONTH FROM evento_reposicao.instante) AS mes,
		EXTRACT(DAY FROM evento_reposicao.instante) AS dia_mes,
		EXTRACT(DOW FROM evento_reposicao.instante) AS dia_semana,
		ponto_de_retalho.distrito AS distrito, 
		ponto_de_retalho.concelho AS concelho, 
		evento_reposicao.unidades AS unidades 
	FROM produto, categoria, evento_reposicao, ponto_de_retalho, planograma
	WHERE produto.cat = categoria.nome 
		AND produto.ean = evento_reposicao.ean 
		AND evento_reposicao.ean = planograma.ean 
		AND planograma.loc = ponto_de_retalho.nome
);
