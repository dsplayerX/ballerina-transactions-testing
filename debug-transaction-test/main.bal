import ballerina/io;

public function main() returns error? {
    transaction {
        int a = 1;
        int b = 0;
        int c = a / b;
        io:println(c);
        check commit;
    }
}
