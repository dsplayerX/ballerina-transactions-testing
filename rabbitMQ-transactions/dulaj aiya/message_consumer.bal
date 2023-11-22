import ballerina/http;
import ballerina/log;
import ballerinax/rabbitmq;

type Doctor record {|
    string name;
    string hospital;
    string category;
    string availability;
    decimal fee;
|};

type ReservationResponse record {|
    int appointmentNumber;
    Doctor doctor;
    Patient patient;
    string hospital;
    boolean confirmed;
    string appointmentDate;
|};

type SmsApiResponse record {|
    "error"|"success" status;
    string[] errors?;
    string data?;
|};

type RabbitMqMessage record {|
    *rabbitmq:AnydataMessage;
    record {|
        *ReservationRequest;
        string category;
    |} content;
|};

// configurable string sms_api_user_id = "";
// configurable string sms_api_api_key = "";
// configurable string sms_api_sender_id = "";

// final http:Client smsApi = check new ("https://app.notify.lk/api/v1");
final http:Client hospitalBackend = check new ("http://localhost:9090");

listener rabbitmq:Listener channelListener = new (rabbitmq:DEFAULT_HOST, rabbitmq:DEFAULT_PORT);

@rabbitmq:ServiceConfig {
    queueName: "ReservationQueue"
}
service rabbitmq:Service on channelListener {
    remote function onMessage(RabbitMqMessage message, rabbitmq:Caller caller) returns error? {

        log:printInfo("Message Recieved to RabbitMQ subscriber", request = message);

        record {|*ReservationRequest; string category;|} {category, hospital_id, ...reservation} = message.content;

        ReservationResponse|http:ClientError resp =
                    hospitalBackend->/[hospital_id]/categories/[category]/reserve.post(reservation);

        if resp !is ReservationResponse {
            log:printError("Reservation request failed", resp);
            return;
        }

        string smsMessage = generateMessage(resp.patient.name, resp.patient.phone, resp.appointmentNumber, resp.hospital);
        log:printInfo(smsMessage);
        
        // SmsApiResponse|http:ClientError smsApiResp =
        //             smsApi->get(string `/send?user_id=${sms_api_user_id}&api_key=${sms_api_api_key}&sender_id=${sms_api_sender_id}&${smsMessage}`);

        // if smsApiResp !is SmsApiResponse {
        //     log:printError("SMS API error", smsApiResp);
        //     return;
        // }

        // if smsApiResp.status == "error" {
        //     log:printError("SMS not sent", smsMessage = smsMessage);
        //     return;
        // }

        check caller->basicAck();
    }
}

function generateMessage(string name, string phoneNo, int appointmentNo, string hospital) returns string
        => string `to=${phoneNo}&message=Dear ${name}, Your appintment accepted at ${hospital}. Appointment No: ${appointmentNo}`;
