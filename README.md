solr-test
=========

Example on how to set up Solr to index data and return search results via a PHP-based application

How to use:

Execute SQL
Execute script located in sql folder

Start Solr
Download the 4.x release from the Solr website and unzip it to a convenient location on your machine (we used /opt/solr-4.2.0/). Solr comes supplied with an example application, ready to run – in a subdirectory of the unzipped Solr build called ‘example’. In the terminal in OS X, a shell in Linux or the command line in Windows, go to the example directory and start Solr:
java -jar start.jar

The Solr admin panel
You can now browse to the Solr admin panel from any web browser at localhost:8983/solr/. You should see the Solr admin panel, which we’ll look at in more detail a little later. If you can’t browse to it, look at the terminal output to see if there are any error messages. If all is well, stop Solr running by hitting Ctrl+C in your terminal.

The Solr schema
In the example app we’re looking at, the schema.xml file lives at
/example/solr/collection1/conf/schema.xml. Browse to this file and open it in your text editor of choice. Next you’re going to add some fields to your schema – these correspond directly to the fields you have already set up in the database. Solr is very flexible, allowing you to define data types with a huge variety of filters, but here we’re using some stock ones from the example schema.
Find the field definition for ‘id (<field name=”id” type=”string” indexed=”true” stored=”true” required=”true” multiValued=”false” />)’ and underneath it, add these lines:

<field name="product_name" type="text_general" indexed="true" stored="true"/>
<field name="product_description" type="text_general" indexed="true" stored="true"/>
<field name="product_price" type="float" indexed="true" stored="true"/>

Check Solr schema
After saving schema.xml, start the Solr instance again using CTRL-C in the command window and start again using java -jar start.jar
. Browse to the admin panel at localhost:8983. If you get any error messages, stop Solr by hitting Ctrl+C, check the schema file has no typos and is properly formed, then try again.

A blank application
Now it’s time to set up your PHP application. You should have a web server set up on your development machine, and a directory that we can use for this tutorial (either the site root, a virtual host or a subdirectory). We’ll refer to this location as the website home directory. We’ll also assume you can browse to the site at http://localhost – if you are using a different hostname, or a subdirectory, just use that instead. Now go to your website home directory and create four empty files with the following names:

export.php
search.php
constants.php
results.php

Time for constants
There are some variables we’ll need to use repeatedly – database connection parameters, and the host, name and port of our Solr instance. To make life easy, we’ll define those in our constants file. Open constants.PHP in your text editor and add the following lines, making sure you add your own database username and password where appropriate:

<?PHP
define(‘DBUSER’, ‘root’); //change this value to your DB     username
define(‘DBPASS’, ‘password’); //change this value to your DB     password
define(‘DBHOST’, ‘localhost’);
define(‘DBSCHEMA’, ‘solr_test’);
define(‘SOLRNAME’, ‘/solr’);
define(‘SOLRPORT’, ‘8983’);
define(‘SOLRHOST’, ‘localhost’);
?>

Solr PHP clients
There are a number of clients available for PHP that work well with Solr, including the excellent Solarium. The simplest to get up and running with is the Solr PHP Client, available from bit.ly/17JAdPp. Download the latest archive and unzip into the root of your web app directory. Once you’ve extracted the archive into a subdirectory (call it SolrPHPCient), you can remove the zip file.

Fixing Solr PHP client
There is an issue with solr-PHP-client that prevents it from working with the current version of Solr (4.2), due to some Solr commands being deprecated. To make sure everything is working as it should, we need to apply a patch file, which is available from http://bit.ly/140TutI. Download the Service.PHP.patch file so it’s in the same directory as Service.PHP in the solr-PHP-client – /SolrPHPClient/Apache/Solr/Service.PHP.patch. Then you can either apply it using the command below, or any patching tool (Netbeans has one built in – just select Tools>Apply Diff Patch from the main menu).

Preparing data
Now let’s add data from the database to the Solr index. We’ll start by writing a skeleton file to connect to the database and grab the records. Open export.PHP in your text editor and add the following lines:

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

Indexing data
You should now be able to browse to localhost/export.PHP and see a result count. Now we know we can connect to the database and access our records, let’s loop through our results and send them to Solr. In export.PHP, replace the line ‘/*We’re going to add rows to Solr here*/’ with this code:

   //declare an empty array to hold our data to send to Solr
   $documents = array();
   require_once(‘/solr-PHP/Service.PHP’);
       $solr = new Apache_Solr_Service(SOLR-HOST, SOLR-PORT,     SOLR_    NAME);
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
?>

Pushing data to Solr
After making sure the Solr server is running (start it if it isn’t), refresh localhost/export.PHP in your browser. Solr will now be populated with the records from our database. There are many ways to get data into Solr, including simply sending it an appropriately formed XML file using CURL. Using the technique above, however, allows us to do some simple error checking and is very effective for replacing the contents of an entire Solr index.

Solr query syntax
Now we can check if the data is actually present by running some simple queries against our Solr instance. The query syntax is rather different to SQL – you start with the field name you want to query, then the data you want to match, like ‘product_name:Vic 20’. To start with, we just want to run a wildcard query to make sure our data is present and correct: ‘*:*’ will do that. We do this by forming an appropriate HTTP GET request directed at our Solr instance and placing the query string in a parameter called ‘q’ – so when we access the URL below, we should see our five records.

Search page skeleton
So we have a Solr index with some data in; now we want to make a form and results page so we can search it from our PHP application. We’ll start by making the form, which in this case is about as basic as it’s possible to get – open search.PHP in your text editor and add the following code:

<html>
     <body>
   <form action=”results.PHP” method=”get”>
     <label for=”query”>Search:</label>
     <input id=”query” name=”query” placeholder=”Enter your     search” />
     <input type=”submit”/>
   </form>
 </body>
</html>

Search page details
Now you have a query form, let’s make a page to get some results. Open results.PHP in your text editor, then put the following comment skeleton in place:

<?PHP
//1. check that a query has been submitted, send user back to     search page otherwise
//2. if we have a query term, connect to Solr, query and grab the     result
//3. check the results – are there any? If not, display an     appropriate message
// if there are results, iterate through them and display
?>

Get the query term
Some basic control here: check that the query string has been submitted, and if not, redirect back to our search page. Obviously all the usual advice about sanitising user input applies – in production, you should treat the user input that you’re passing to Solr with the same caution you’d use with anything being passed to a database server. So, in results.PHP, enter the following code under the comment that starts ‘//1. check that a query…’

if(!isset($_REQUEST[‘query’]) || empty($_REQUEST[‘query’]))
{
header(“Location: http://localhost/search.PHP”);
}
else
{
    $query = $_REQUEST[‘query’];
}

Query Solr
We have a query, so we are going to connect to Solr using the same mechanism as we used when populating the index. Then we’ll use the search method of the Solr PHP library, which accepts a query string, an offset and a limit as parameters – the offset and limit work exactly as they do with MySQL queries, determining the starting record and the number of results respectively. So, in results.PHP, enter the following code under the comment that starts ‘//2. if we have a query term…’

//our required includes
require_once(‘constants.PHP’);
requ
//instantiate a Solr object
$solr = new Apache_Solr_Service(SOLRHOST, SOLRPORT, SOLRNAME);
//run the query
$results = $solr->search($query, 0, 10);ire_        008    once(‘SolrPHPClient/    Apache/Solr/Service.PHP’);

Checking results
Now you have a results object, which is stored in $results. First,
check that the query ran successfully by testing that results is not empty –
$solr->query will return false if it failed. If all is well, then get the number of results, which is stored in $results->response->numFound, and display it appropriately. So, under the comment that starts ‘//3. check the results…’

Display results
By now you’ll know whether the query ran and if it has produced any results, so the next stage is to iterate through them and display them to the user. We are passing the results through htmlspecialchars() to make sure any special characters in the Solr output are converted to appropriate HTML entities. So, in results.PHP enter the following under the comment that starts ‘//4. if there are results…’

   echo ‘<table>’;
   echo ‘<tr><th>ID</th>’ .
              ‘<th>Name</th>’ .
              ‘<th>Description</th>’ .
          ‘<th>Price</th></tr>’;
    {
        foreach($results->response->docs as $doc)
        {
echo ‘<tr><td>’ . htmlspecialchars($doc->id) . ‘</td>’ .
  ‘<td>’ . htmlspecialchars($doc->product_name) .      ‘</td>’ .
            ‘<td>’ . htmlspecialchars($doc->product_        description)  . ‘</td>’ .
                    ‘<td>’ . htmlspecialchars($doc->product_price) .     ‘</td></tr>’;
        }
    }
    echo ‘</table>’;

Error handling
Finally, you can add a little error handling around the Solr statement (this can also be applied to the export.PHP file). As we’re connecting to an external service (our Solr server), there is an obvious risk that the service may be unavailable, causing a fatal error. So here we can wrap the connection in a try/catch block, to handle the error and display an appropriate message.

try
{
    //instantiate a Solr object
$solr = new Apache_Solr_Service(SOLRHOST, SOLRPORT, SOLRNAME);
    //run the query
    $results = $solr->search($query, 0, 10);
}
catch(Exception $e)
{
    //you would probably want to log this error and display an     appropriate 
    //(user friendly) message on a production site
    echo($e->__toString());
}

Running a search
You can now browse to localhost/search.PHP and try a search like ‘product_name:Vic’ or ‘*:*’. This will produce a selection of search results as typically found when searching any other site.

Possible issues:

Check constants and see how they were used export.php.
(for example it was defined DBPASS you used DB-PASSWORD)

http://www.webdesignermag.co.uk/tutorials/how-to-add-search-with-solr/
https://github.com/basdenooijer/solarium
http://localhost/solr-test/www/vendor/solarium/solarium/examples/1.1-check-solarium-and-ping.php
