import ballerina/http;

type Order readonly & record {
    int orderId;
    string productName;
    decimal price;
    boolean isValid;
};

service / on new http:Listener(8083) {
    private final http:Client parClient;
    // private final http:Client parTwoClient;
    function init() returns error? {
        self.parClient = check new("http://localhost:9092");
        // self.parTwoClient = check new("http://localhost:9090");
    }

    resource function post orders(Order newOrder) returns http:Accepted|error {
        // Publishes the message using the `newClient` and the routing key named `OrderQueue`.
        transaction {
            http:Response response = check self.parClient->post("/orders", newOrder);
            // http:Response responseTwo = check self.parTwoClient->get("/updateDb");
            check commit;
        }

        return http:ACCEPTED;
    }
}
