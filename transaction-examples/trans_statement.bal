import ballerina/io;

public function main() returns error? {
    // The transaction statement begins a new transaction and executes a block.
    transaction {
        check doStage1();
        doStage2();
 
        // Commit of a transaction must be done explicitly using commit.
        // A commit must be lexically within a transaction statement and may return an error;
        check commit;

    }
    return;

}

function doStage1() returns error? {
    transaction {
        check commit;
    }
}

transactional function doStage2() {
    io:println("Stage2 completed");
}
