import ballerina/http;
import ballerina/io;
import ballerina/random;

type Room record {|
    int number;
|};

type Payment record {|
    decimal amount;
|};

isolated service / on new http:Listener(8081) {
    private http:Client roomsReserveClient;
    private http:Client paymentClient;

    function init() returns error? {
        self.roomsReserveClient = check new ("http://localhost:9000/reservations");
        self.paymentClient = check new ("http://localhost:9003/finance");

    }
    isolated resource function post bookings(Room room) returns error? {

        check callDistributedTrxFunction(self.roomsReserveClient, self.paymentClient);

    }
}

isolated function callDistributedTrxFunction(http:Client roomsReserveClient, http:Client paymentClient) returns error? {
    transaction {
        http:Response|http:ClientError res1 = check roomsReserveClient->/rooms.post({"number": 1});
        if (res1 is http:Response && res1.statusCode != 200) {
            io:println(res1.statusCode);
            rollback;
            check error("Error occurred while reserving rooms");
        } else {
            http:Response|http:ClientError res2 = check paymentClient->/payments.post({"amount": 1000});
            if (res2 is http:Response && res2.statusCode != 200) {
                rollback;
                fail error("Error occurred while paying for room");
            } else {
                check commit;
                io:println("Transaction completed successfully");
            }
        }
    }
}

service /reservations on new http:Listener(9000) {
    transactional resource function post rooms(Room room) returns error|http:Ok {
        io:println(`room ${room.number} is reserved`);
        // transaction:onCommit(sendEmail);
        // transaction:onRollback(releaseRooms);
        return http:OK;
    }
}

service /finance on new http:Listener(9003) {
    resource function post payments(Payment payment) returns error|http:Ok {
        transaction {
            int|random:Error randomNumber = random:createIntInRange(0, 5);
            if randomNumber is random:Error || randomNumber < 3 {
                rollback;
                io:println(`payment failed due to random number ${randomNumber}`);
                return error("payment failed");
            } else {
                check commit;
                io:println(`payment sucessfull with random number ${randomNumber} and amount ${payment.amount}`);
                return http:OK;
            }
        }
    }
}

