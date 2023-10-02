import ballerina/io;

public function main() returns error? {
    transaction {
        check printhello();
        check printhello2();
        check commit;
    }
}

public function printhello() returns error? {
    io:println("Hello, Transaction!");
    boolean trans = transactional;
    io:print(trans);
}

public function printhello2() returns error? {
    io:println("Hello, 2nd!");
}