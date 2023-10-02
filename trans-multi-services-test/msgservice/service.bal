import ballerina/http;
import ballerina/io;

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9092) {
    transactional resource function get sendmsg(string msg) returns string|error {
        if (msg == "") {
            return error("Message is empty!");
        } else {
            io:println("User msg: ", msg);
            return "Msg sent successfully";
        }
    }
}

function msgprint(string msg) {
}
