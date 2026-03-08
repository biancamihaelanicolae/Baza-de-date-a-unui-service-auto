const express = require('express');
const oracledb = require('oracledb');
const bodyParser = require('body-parser');
const path = require('path');

const app = express();

// Setări motor de vizualizare (EJS)
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));
app.use(bodyParser.urlencoded({ extended: true }));

// Configurare conexiune Oracle
const dbConfig = {
    user: "system",
    password: "Biancanico", 
    connectString: "localhost:1521/xe"
};

// RUTA HOME: Te trimite automat la tabelul angajati
app.get('/', (req, res) => {
    res.redirect('/tabel/angajati');
});

//Listare, Sortare și Ștergere Dinamică
app.get('/tabel/:numeTabel', async (req, res) => {
    let connection;
    try {
        connection = await oracledb.getConnection(dbConfig);
        const tabel = req.params.numeTabel.toUpperCase();
        const sortare = req.query.sort || '1';

        const result = await connection.execute(
            `SELECT * FROM ${tabel} ORDER BY ${sortare}`,
            [], 
            { outFormat: oracledb.OUT_FORMAT_OBJECT }
        );

        const coloane = result.metaData.map(meta => meta.name);

        res.render('generic_table', { 
            date: result.rows, 
            coloane: coloane, 
            numeTabel: tabel 
        });
    } catch (err) {
        res.status(500).send("Eroare la încărcarea tabelului: " + err.message);
    } finally {
        if (connection) await connection.close();
    }
});

// b)UPDATE DINAMIC
app.post('/update/:tabel', async (req, res) => {
    let connection;
    try {
        connection = await oracledb.getConnection(dbConfig);
        const tabel = req.params.tabel.toUpperCase();
        const data = req.body; // Datele trimise din formular
        
        // Extragem numele coloanelor și valorile
        const coloane = Object.keys(data);
        const valori = Object.values(data);
        
        // Identificăm cheia primară 
        const numeID = coloane[0];
        const valoareID = valori[0];

        // Construim clauza SET 
        const setClause = coloane.map((col, index) => `${col} = :${index + 1}`).join(', ');

        const sql = `UPDATE ${tabel} SET ${setClause} WHERE ${numeID} = :id`;
        
        // Adăugăm ID-ul la finalul listei de valori pentru clauza WHERE
        const bindParams = [...valori, valoareID];

        await connection.execute(sql, bindParams, { autoCommit: true });
        
        res.redirect(`/tabel/${tabel}`);
    } catch (err) {
        res.status(500).send("Eroare la actualizare: " + err.message);
    } finally {
        if (connection) await connection.close();
    }
});

// RUTA PENTRU ȘTERGERE 
app.get('/delete/:tabel/:idColoana/:idValoare', async (req, res) => {
    let connection;
    try {
        connection = await oracledb.getConnection(dbConfig);
        const { tabel, idColoana, idValoare } = req.params;
        
        await connection.execute(
            `DELETE FROM ${tabel.toUpperCase()} WHERE ${idColoana.toUpperCase()} = :id`,
            [idValoare],
           { autoCommit: true }
        );
        
        await connection.commit();
        res.redirect(`/tabel/${tabel}`);
    } catch (err) {
        res.status(500).send("Eroare la ștergere: " + err.message);
    } finally {
        if (connection) await connection.close();
    }
});

//Raport 3 tabele + 2 condiții
app.get('/raport-complex', async (req, res) => {
    let connection;
    try {
        connection = await oracledb.getConnection(dbConfig);
        const query = `
            SELECT c.nume, c.prenume, a.numar_inmatriculare, m.denumire_marca, a.pret_reparatie
            FROM CLIENTI c
            JOIN AUTOVEHICULE a ON c.id_client = a.id_client
            JOIN MARCI m ON a.id_marca = m.id_marca
            WHERE a.tip_autovehicul = 'SUV' 
              AND a.pret_reparatie > 2000`;
        const result = await connection.execute(query, [], { outFormat: oracledb.OUT_FORMAT_OBJECT });
        res.render('raport', { date: result.rows });
    } catch (err) { res.send(err.message); }
    finally { if (connection) await connection.close(); }
});

// Funcții grup și HAVING
app.get('/statistici-salarii', async (req, res) => {
    let connection;
    try {
        connection = await oracledb.getConnection(dbConfig);
        const query = `
            SELECT id_departament, AVG(salariu) AS medie, COUNT(*) AS nr_angajati
            FROM ANGAJATI
            GROUP BY id_departament
            HAVING AVG(salariu) > 5000`;
        const result = await connection.execute(query, [], { outFormat: oracledb.OUT_FORMAT_OBJECT });
        res.render('statistici', { date: result.rows });
    } catch (err) { res.send(err.message); }
    finally { if (connection) await connection.close(); }
});

//  Vizualizări
app.get('/vizualizari', async (req, res) => {
    let connection;
    try {
        connection = await oracledb.getConnection(dbConfig);
        const result = await connection.execute(`SELECT * FROM V_TOP_REPARATII`, [], { outFormat: oracledb.OUT_FORMAT_OBJECT });
        res.render('vizualizari', { date: result.rows });
    } catch (err) { res.send(" View creat în SQL Developer: " + err.message); }
    finally { if (connection) await connection.close(); }
});

// Rută pentru Vizualizarea Simplă 
app.get('/alerta-stoc', async (req, res) => {
    let connection;
    try {
        connection = await oracledb.getConnection(dbConfig);
        const result = await connection.execute(
            `SELECT * FROM V_PIESE_STOC`, 
            [], 
            { outFormat: oracledb.OUT_FORMAT_OBJECT }
        );
       
        res.render('vizualizare_simpla', { 
            date: result.rows, 
            titlu: "Alertă Stoc Scăzut (View Simplu)" 
        });
    } catch (err) { res.send(err.message); }
    finally { if (connection) await connection.close(); }
});

// Pornire Server
const PORT = 3000;
app.listen(PORT, () => {
    console.log(`Server pornit cu succes!`);
    console.log(`Accesează: http://localhost:${PORT}/tabel/angajati`);
});