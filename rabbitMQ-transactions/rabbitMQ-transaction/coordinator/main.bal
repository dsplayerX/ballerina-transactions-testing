import ballerina/http;
import ballerina/sql;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;
import ballerinax/rabbitmq;

type Order readonly & record {
    int orderId;
    string productName;
    decimal price;
    boolean isValid;
};

service / on new http:Listener(9092) {
    private final rabbitmq:Client orderClient;
    private final mysql:Client testDB;

    function init() returns error? {
        // Initiate the RabbitMQ client at the start of the service. This will be used
        // throughout the lifetime of the service.
        self.orderClient = check new (rabbitmq:DEFAULT_HOST, rabbitmq:DEFAULT_PORT);
        self.testDB = check new (host = "localhost",
            user = "root", password = "my-secret-pw",
            port = 3308, database = "test",
            options = {useXADatasource: true}
        );
    }

    resource function post orders(Order newOrder) returns http:Accepted|error {
        // Publishes the message using the `newClient` and the routing key named `OrderQueue`.
        transaction {
            check self.orderClient->publishMessage({
                content: newOrder,
                routingKey: "OrderQueue"
                });

            sql:ParameterizedQuery query = `INSERT INTO test (hello) VALUES ('rabbits')`;
            sql:ExecutionResult _ = check self.testDB->execute(query);

            check commit;
        }

        return http:ACCEPTED;
    }
}
