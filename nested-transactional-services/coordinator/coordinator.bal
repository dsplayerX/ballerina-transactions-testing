import ballerina/http;
import ballerina/io;

service / on new http:Listener(9110) {

    resource function get doTransaction() returns http:Accepted|http:NotAcceptable|http:InternalServerError {
        boolean? successful = false;
        do {
            transaction {
                transaction:onCommit(commitDone);
                transaction:onRollback(rollbackDone);
                successful = check callRemoteService();
                if successful is boolean {
                    if successful {
                        check commit;
                        return <http:Accepted>{
                        body: "Notified remote service to commit :)"
                        };
                    } else {
                        rollback;
                        return <http:NotAcceptable>{
                        body: "Error  during transaction, rolled back"
                        };
                    }
                } else {
                    rollback;
                    return <http:InternalServerError>{
                    body: "Error calling remote service"
                    };
                }
            }
        } on fail {
            return <http:InternalServerError>{
            body: "Error during transaction execution"
            };
        }

    }
}

transactional function callRemoteService() returns boolean|error? {
    http:Client httpClient = check new ("http://localhost:9111");
    http:Response response = check httpClient->get("/updateDb");
    io:println("Response from remote service: ", response.statusCode, " ", response.reasonPhrase);
    if (response.statusCode == 202) {
        return true;
    } else {
        return false;
    }
}

isolated function commitDone('transaction:Info info) {
    io:println("> Initiator committed.");
}

isolated function rollbackDone(transaction:Info info, error? cause, boolean willRetry) {
    io:println("> Initiaor rollbacked.");
}
