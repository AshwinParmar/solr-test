<?PHP
require(‘constants.PHP’);
$mysqli = new mysqli(‘DBHOST’, ‘DBUSER’, ‘DBPASS’, DBSCHEMA);
if ($mysqli->connect_errno) {
   echo “Failed to connect to MySQL: (“ . $mysqli->connect_    errno     . “) “ . $mysqli->connect_error;
}
/* Select queries return a resultset */
if ($result = $mysqli->query(“SELECT * FROM products”)) {
   printf(“Select returned %d rows.\n”, $result->num_rows);
    /*We’re going to add rows to Solr here*/
  /* free result set */
  $result->close();
}
