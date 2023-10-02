import ballerina/http;

service /employees on new http:Listener(8080) {

    isolated resource function post .(@http:Payload Product prod) returns int|error? {
        return addProduct(prod);
    }
    
    isolated resource function get [int id]() returns Product|error? {
        return getProduct(id);
    }
    
    isolated resource function get .() returns Product[]|error? {
        return getAllProducts();
    }
    
    isolated resource function put .(@http:Payload Product prod) returns int|error? {
        return updateProduct(prod);
    }
    
    isolated resource function delete [int id]() returns int|error? {
        return removeProduct(id);       
    }

}