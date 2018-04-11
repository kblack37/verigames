package cgs.server.logging.responses;


interface IServerResponse
{
    
    /**
		 * Set the data recieved from the URL request. The data type corresponds
		 * to the data type specified in the server request. Possible values
		 * include values in URLLoaderDataFormat.
		 */
    var data(never, set) : Dynamic;

}
