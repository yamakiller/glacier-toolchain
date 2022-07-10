package impl

const (
	insertExampleSQL = `INSERT INTO examples (
		id,create_at,create_by,update_at,update_by,name,author
	) VALUES (?,?,?,?,?,?,?);`

	updateExampleSQL = `UPDATE examples SET update_at=?,update_by=?,name=?,author=? WHERE id =?`

	queryExampleSQL = `SELECT * FROM examples`

	deleteExampleSQL = `DELETE FROM examples WHERE id = ?`
)