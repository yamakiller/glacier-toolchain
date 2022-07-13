package impl

const (
	insertExampleSQL = `INSERT INTO {{.AppName}}s (
		id,create_at,create_by,update_at,update_by,name,author
	) VALUES (?,?,?,?,?,?,?);`

	updateExampleSQL = `UPDATE {{.AppName}}s SET update_at=?,update_by=?,name=?,author=? WHERE id =?`

	queryExampleSQL = `SELECT * FROM {{.AppName}}s`

	deleteExampleSQL = `DELETE FROM {{.AppName}}s WHERE id = ?`
)