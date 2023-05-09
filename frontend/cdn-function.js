function handler(event) {
    // Function for viewer request event trigger
    var request = event.request;
    var uri = request.uri;
    var newurl = uri;
  
    // Rewrite /foo to /foo.html if it exists
    if (uri !== "/" && !uri.endsWith("/")) {
      newurl = uri + ".html";
    }
  
    // Otherwise, rewrite /foo to /foo/index.html if it exists
    if (uri.endsWith("/")) {
      newurl = uri + "index.html";
    }
  
    // Redirect any requests to remove a trailing slash
    if (uri !== "/" && uri.endsWith("/")) {
      newurl = uri.substring(0, uri.length - 1);
      var response = {
        statusCode: 301,
        statusDescription: 'Moved Permanently',
        headers: {
          'location': { value: newurl }
        }
      };
      return response;
    }
  
    // Prevent any further processing if the URL already ends with a file extension
    if (uri.includes(".")) {
      return request;
    }
  
    // Rewrite the request URI with the new URL
    request.uri = newurl;
    
    return request;
  }