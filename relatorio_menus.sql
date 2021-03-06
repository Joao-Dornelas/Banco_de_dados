DECLARE @CUSTOM CHAR = '1', @MENU VARCHAR(30) = '', @FUNCAO VARCHAR(15) = '', @ROTINA VARCHAR(30) = ''

;WITH MENU AS
(
	SELECT 
		RTRIM(M_MODULE) + ' - ' + RTRIM(M_NAME) AS M_NAME,
		M_ID
	FROM MPMENU_MENU
	WHERE D_E_L_E_T_ = ''
		AND M_NAME NOT LIKE '#BKP%'
		
)
, FUNC AS
(
	SELECT 
		A.M_NAME,
		RTRIM(D.F_FUNCTION) AS F_FUNCTION,
		RTRIM(C.N_DESC) AS N_DESC,
		A.M_ID AS ID_MENU,
		B.I_FATHER AS PAI_FUNC
	FROM MENU AS A
	LEFT JOIN MPMENU_ITEM AS B	
		ON B.I_ID_MENU = A.M_ID AND B.D_E_L_E_T_ = '' AND B.I_ID_FUNC <> ''
	LEFT JOIN MPMENU_I18N AS C	
		ON C.N_PAREN_ID = B.I_ID AND C.N_LANG = '1' AND C.D_E_L_E_T_ = ''
	LEFT JOIN MPMENU_FUNCTION AS D
		ON D.F_ID = B.I_ID_FUNC AND D.D_E_L_E_T_ = '' 
)
,IT1 AS
(
	SELECT 
		A.M_NAME,
		A.F_FUNCTION,
		A.N_DESC AS DESC_FUNC,
		RTRIM(C.N_DESC) AS DESC_IT1,
		A.ID_MENU,
		B.I_FATHER AS PAI_IT1
	FROM FUNC AS A
	LEFT JOIN MPMENU_ITEM AS B	
		ON B.I_ID = A.PAI_FUNC AND B.D_E_L_E_T_ = ''
	LEFT JOIN MPMENU_I18N AS C 
		ON C.N_PAREN_ID = B.I_ID
		AND C.N_LANG = '1' AND C.D_E_L_E_T_ = ''
)
,IT2 AS
(
	SELECT 
		A.M_NAME,
		A.F_FUNCTION,
		A.DESC_FUNC,
		A.DESC_IT1,
		RTRIM(C.N_DESC) AS DESC_IT2,
		A.ID_MENU,
		B.I_FATHER AS PAI_IT2
	FROM IT1 AS A
	LEFT JOIN MPMENU_ITEM AS B	
		ON B.I_ID = A.PAI_IT1 AND B.D_E_L_E_T_ = ''
	LEFT JOIN MPMENU_I18N AS C 
		ON C.N_PAREN_ID = B.I_ID
		AND C.N_LANG = '1' AND C.D_E_L_E_T_ = ''
)
,IT3 AS
(
	SELECT 
		A.M_NAME,
		A.F_FUNCTION,
		A.DESC_FUNC,
		A.DESC_IT1,
		A.DESC_IT2,
		RTRIM(C.N_DESC) AS DESC_IT3,
		A.ID_MENU,
		B.I_FATHER AS PAI_IT3
	FROM IT2 AS A
	LEFT JOIN MPMENU_ITEM AS B	
		ON B.I_ID = A.PAI_IT2 AND B.D_E_L_E_T_ = ''
	LEFT JOIN MPMENU_I18N AS C 
		ON C.N_PAREN_ID = B.I_ID
		AND C.N_LANG = '1' AND C.D_E_L_E_T_ = ''
)
,IT4 AS
(
	SELECT 
		A.M_NAME,
		A.F_FUNCTION,
		A.DESC_FUNC,
		A.DESC_IT1,
		A.DESC_IT2,
		A.DESC_IT3,
		RTRIM(C.N_DESC) AS DESC_IT4,
		A.ID_MENU,
		B.I_FATHER AS PAI_IT4
	FROM IT3 AS A
	LEFT JOIN MPMENU_ITEM AS B	
		ON B.I_ID = A.PAI_IT3 AND B.D_E_L_E_T_ = ''
	LEFT JOIN MPMENU_I18N AS C 
		ON C.N_PAREN_ID = B.I_ID
		AND C.N_LANG = '1' AND C.D_E_L_E_T_ = ''
)
,IT5 AS
(
	SELECT
		A.M_NAME,
		A.F_FUNCTION,
		A.DESC_FUNC,
		A.DESC_IT1,
		A.DESC_IT2,
		A.DESC_IT3,
		A.DESC_IT4,
		RTRIM(C.N_DESC) AS DESC_IT5,
		A.ID_MENU,
		B.I_FATHER AS PAI_IT5
	FROM IT4 AS A
	LEFT JOIN MPMENU_ITEM AS B	
		ON B.I_ID = A.PAI_IT4 AND B.D_E_L_E_T_ = ''
	LEFT JOIN MPMENU_I18N AS C 
		ON C.N_PAREN_ID = B.I_ID
		AND C.N_LANG = '1' AND C.D_E_L_E_T_ = ''
)

SELECT 
	MD.N_DESC,
	M_NAME, 
	F_FUNCTION, 
	[CAMINHO] = REPLACE(ISNULL(DESC_IT5,'') + IIF(DESC_IT5 IS NULL, '',' > ') + ISNULL(DESC_IT4,'') + IIF(DESC_IT4 IS NULL, '',' > ') + ISNULL(DESC_IT3,'') + IIF(DESC_IT3 IS NULL, '',' > ') + ISNULL(DESC_IT2,'') + IIF(DESC_IT2 IS NULL, '',' > ') + DESC_IT1,'&',''), 
	DESC_FUNC
FROM IT5 AS TB
LEFT JOIN MPMENU_I18N AS MD	ON MD.N_PAREN_ID = TB.ID_MENU AND MD.N_LANG = '1' AND MD.D_E_L_E_T_ = ''
WHERE M_NAME LIKE CASE WHEN @MENU <> '' THEN '%' + @MENU + '%' ELSE M_NAME END
	AND F_FUNCTION = CASE WHEN @FUNCAO <> '' THEN @FUNCAO ELSE F_FUNCTION END
	AND UPPER(DESC_FUNC) LIKE CASE WHEN @ROTINA <> '' THEN '%'+UPPER(@ROTINA)+'%' ELSE UPPER(DESC_FUNC) END
ORDER BY MD.N_DESC, M_NAME, [CAMINHO] 
