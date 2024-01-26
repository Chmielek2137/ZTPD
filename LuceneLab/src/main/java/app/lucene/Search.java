package app.lucene;

import org.apache.lucene.analysis.pl.PolishAnalyzer;
import org.apache.lucene.document.Document;
import org.apache.lucene.index.DirectoryReader;
import org.apache.lucene.index.IndexReader;
import org.apache.lucene.index.StoredFields;
import org.apache.lucene.queryparser.classic.ParseException;
import org.apache.lucene.queryparser.classic.QueryParser;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.Query;
import org.apache.lucene.search.ScoreDoc;
import org.apache.lucene.search.TopDocs;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.FSDirectory;

import java.io.IOException;
import java.nio.file.Paths;

public class Search {

    private static final String INDEX_DIRECTORY = "./src/main/resources/index";

    public static void main(String[] args) throws IOException, ParseException {

        //EnglishAnalyzer analyzer = new EnglishAnalyzer();
        PolishAnalyzer analyzer = new PolishAnalyzer();

        Directory directory = FSDirectory.open(Paths.get(INDEX_DIRECTORY));

        //String querystr = "*:*";
        //String querystr = "dummy";
        //String querystr = "and";

        //String querystr = "isbn:9780062316097";
        //String querystr = "title:urodzić";
        //String querystr = "title:rodzić";
        //String querystr = "title:ro*";
        //String querystr = "title:ponieważ";
        //String querystr = "title:Lucyna OR title:akcja";
        //String querystr = "title:akcja AND NOT title:Lucyna";
        //String querystr = "\"naturalnie morderca\"";
        //String querystr = "naturalne";
        String querystr = "naturalne~";
        Query q = new QueryParser("title", analyzer).parse(querystr);

        //9: EnglishAnalyzer ma listę StopWords i nie wyszukuje po nich. Dodatkowo potrafi znaleźć tekst z odmienionym słowem

        int maxHits = 10;
        IndexReader reader = DirectoryReader.open(directory);
        IndexSearcher searcher = new IndexSearcher(reader);
        TopDocs docs = searcher.search(q, maxHits);
        ScoreDoc[] hits = docs.scoreDocs;

        System.out.println("Found " + hits.length + " matching docs.");

        StoredFields storedFields = searcher.storedFields();
        for(int i=0; i<hits.length; ++i) {
            int docId = hits[i].doc;
            Document d = storedFields.document(docId);
            System.out.println((i + 1) + ". " + d.get("isbn")
                    + "\t" + d.get("title"));
        }

        reader.close();
    }
}
