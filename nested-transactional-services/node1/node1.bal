import ballerina/http;
import ballerina/io;

service / on new http:Listener(9111) {
    transactional resource function get updateDb() returns http:Accepted|http:NotAcceptable|http:InternalServerError {
        do{
            http:Client httpClient = check new ("http://localhost:9112");
            http:Response response = check httpClient->get("/updateDb");
            io:println("Response from remote service: ", response.statusCode, " ", response.reasonPhrase);
            if (response.statusCode == http:STATUS_ACCEPTED) {
                return <http:Accepted>{
                        body: string `Accepted`
                        };
            } else {
                return <http:NotAcceptable>{
                        body: string `Not Acceptable`
                        };
            }
        } on fail {
            return <http:InternalServerError>{
                    body: string `Internal Server Error`
                    };
        }
    }

}

isolated function commitDone('transaction:Info info) {
    io:println("> Node 1 committed.");
}

isolated function rollbackDone(transaction:Info info, error? cause, boolean willRetry) {
    io:println("> Node 1 rollbacked.");
}
