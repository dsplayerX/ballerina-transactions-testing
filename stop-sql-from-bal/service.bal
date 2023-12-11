import ballerina/http;
import ballerina/io;
import ballerina/os;

service / on new http:Listener(9292) {

    resource function get startSql() returns boolean|error {
        os:Process|os:Error result = os:exec({value: "net", arguments: ["start", "MYSQL81"]});
        if (result is os:Error) {
            io:println("Error occurred while executing the command: ", result.message());
            return false;
        }
        byte[]|os:Error err = result.output(io:stderr);
        if (err is os:Error) {
            io:println("Error occurred while reading the output: ", err.message());
            return false;
        }
        io:println("Output: ", string:fromBytes(err));
        return true;
    }

    resource function get stopSql() returns boolean|error {
        os:Process|os:Error result = os:exec({value: "net", arguments: ["stop", "MYSQL81"]});
        if (result is os:Error) {
            io:println("Error occurred while executing the command: ", result.message());
            return false;
        }
        byte[]|os:Error err = result.output(io:stderr);
        if (err is os:Error) {
            io:println("Error occurred while reading the output: ", err.message());
            return false;
        }
        io:println("Output: ", string:fromBytes(err));
        return true;
    }

}
