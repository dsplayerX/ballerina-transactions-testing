import ballerina/io;
import ballerina/sql;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

public type RecoverRecord record {|
    int formatId;
    int gtrid_length;
    int bqual_length;
    string data;
|};

public function main() returns error? {
    mysql:Client localDB = check new (host = "localhost",
        user = "root", password = "root",
        port = 3306, database = "m1",
        options = {useXADatasource: true}
    );

    io:println("Database initialized.");

    stream<RecoverRecord, error?> resultStream = localDB->query(`XA RECOVER CONVERT XID;`);
    io:println("XA RECOVER query executed.");

    RecoverRecord[] recoverRecords = [];
    check from RecoverRecord recoverRecord in resultStream
        do {
            recoverRecords.push(recoverRecord);
        };
    check resultStream.close();

    // io:println(recoverRecords);

    foreach RecoverRecord recoverRecord in recoverRecords {
        // io:println(recoverRecord.data.length());
        if (recoverRecord.data.length() == 194) {
            // io:println(datar.substring(2, 98));
            // io:println(datar.substring(98));   
            // string commitString = string;
            // sql:ParameterizedQuery commitQuery = ;

            var _ = check localDB->query(`XA COMMIT 
                                    X'${recoverRecord.data.substring(2, 98)}',
                                    X'${recoverRecord.data.substring(98)}',${recoverRecord.formatId};`);
        }

    }

}
