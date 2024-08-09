import ballerina/log;
import ballerina/lang.runtime;

public function main() returns error? {
    transaction {
        check longRunningTask();
        check commit;
    }
}

transactional function longRunningTask() returns error? {
    foreach int i in 0...120 { // 120 because the cleaup transaction clears transactions after 120s
        log:printDebug(string`Time elapsed: ${i}s`);
        runtime:sleep(1);
    }
}
