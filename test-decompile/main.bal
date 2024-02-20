import ballerina/io;

public function main() returns error? {
    transaction {
        io:println("Hello, World!");
        check commit;
    }
}
