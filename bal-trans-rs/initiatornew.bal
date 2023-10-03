import ballerina/http;
import ballerina/log;
// import ballerina/io;

// This is the initiator of the distributed transaction.
service / on new http:Listener(8080) {

    resource function get .(http:Caller conn, http:Request req) {
        http:Response res = new;
        log:printInfo("Initiating transaction...");
        // When the `transaction` statement starts, a distributed transaction context is created.
        transaction {
            transaction:onCommit( printInitiatorCommit);
            transaction:onRollback( printInitiatorRollback);
            // Print the current transaction ID
            log:printInfo("Started transaction: ");
            // When a participant is called, the transaction context is propagated, and that participant
            // gets infected and joins the distributed transaction.
            boolean successful = check callBusinessService();
            if (successful) {
                res.statusCode = http:STATUS_OK;
                check commit;
            } else {
                res.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                rollback;
            }
        // As soon as the `transaction` block ends, the `2-phase commit
        // coordination` protocol will run. All participants are prepared
        // and depending on the joint outcome, either a `notify commit` or
        // `notify abort` will be sent to the participants.
        }
        on fail {
            log:printError("On Fail - Error occurred while executing the transaction");
            res.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
        }
        // Send the response back to the client.
        var result = conn->respond(res);
        if (result is error) {
            log:printError("Could not send response back to client",
                            err = result.message());
        } else {
            log:printInfo("Sent response back to client");
        }
    }
}

// This is the participant business function call.
function callBusinessService() returns boolean|error {
    http:Client participantEP = check new ("http://localhost:8889/stockquote");
    // Generate the payload
    float price = 300;
    json bizReq = {symbol: "GOOG", price: price};
    // Send the request to the backend service.
    http:Request req = new;
    req.setJsonPayload(bizReq);
    http:Response|error result = check participantEP->post("/update", req);
    log:printInfo("Got response from bizservice");
    if (result is error) {
        log:printError("Error when calling the backend: ", result);
        return false;
    } else {
        return result.statusCode == http:STATUS_OK;
    }
}



// The participant function that will get called when the distributed
// transaction is committed.
isolated function printInitiatorCommit('transaction:Info info) {
    log:printInfo("Initiated transaction committed");
}

isolated function printInitiatorRollback(transaction:Info info, error? cause, boolean willRetry) {
    log:printInfo("Initiated transaction rollbacked");
}