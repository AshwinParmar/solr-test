<?PHP
require('constants.php');
require_once('/solr-PHP/Service.PHP');
$mysqli = new mysqli(DBHOST, DBUSER, DBPASS, DBSCHEMA);
if ($mysqli->connect_errno) {
   echo "Failed to connect to MySQL: (" . $mysqli->connect_errno     . ") " . $mysqli->connect_error;
}
/* Select queries return a resultset */
if ($result = $mysqli->query("SELECT * FROM products")) {
   printf("Select returned %d rows.\n", $result->num_rows);
    /*We’re going to add rows to Solr here*/
    
//declare an empty array to hold our data to send to Solr
$documents = array();
$solr = new Apache_Solr_Service(SOLRHOST, SOLRPORT,SOLRNAME);
while ($result = $results->fetch_object())
      {
    // For each result, create a new Solr doc
    $document = new Apache_Solr_Document();
    $document->id  = $result->product_id;
    $document->description = $result->description;
    $document->name = $result->name;
    $document->price = $result->price;
    //add document to array
    $documents[] = $document;
}
if(!empty($documents))
{
    $solr->addDocuments($documents);
    $solr->commit();
    $solr->optimize();
}
    
  /* free result set */
  $result->close();
}
