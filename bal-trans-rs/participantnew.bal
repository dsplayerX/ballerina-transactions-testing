import ballerina/http;
// import ballerina/io;
import ballerina/log;
// import ballerina/lang.'transaction as trx;

// This service is a participant in the distributed transaction. It will get
// infected when it receives a transaction context from the participant. The
// transaction context, in the HTTP case, will be passed in as custom HTTP headers.
service /stockquote on new http:Listener(8889) {

  transactional resource function post update(http:Caller conn, http:Request req) returns error? {

    // Print the current transaction ID.
    log:printInfo("Joined transaction");

    // Get the json payload.
    json|error? updateReq = <@untainted>req.getJsonPayload();

    // Generate the response.
    http:Response res = new;
    if (updateReq is json) {
        string symbb = (check updateReq.symbol).toString();
        string pricee = (check updateReq.symbol).toString();

      string msg = string`Update stock quote request received. symbol:${symbb}, price:${pricee}`;
      log:printInfo(msg);
      json jsonRes = {"message": "updating stock"};
      res.statusCode = http:STATUS_OK;
      res.setJsonPayload(jsonRes);
    } else {
      res.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
      res.setJsonPayload(updateReq.toBalString());
      log:printError("Payload error occurred!", updateReq);
    }

    // Send the response back to the initiator.
    var result =  conn->respond(res);
    if (result is error) {
      log:printError("Could not send response back to initiator",
              err = result.toBalString());
    } else {
      log:printInfo("Sent response back to initiator");
    }
  }
}