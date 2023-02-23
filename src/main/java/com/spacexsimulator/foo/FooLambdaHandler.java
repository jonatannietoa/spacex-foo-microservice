package com.spacexsimulator.foo;

import com.amazonaws.serverless.exceptions.ContainerInitializationException;
import com.amazonaws.serverless.proxy.model.AwsProxyResponse;
import com.amazonaws.serverless.proxy.model.HttpApiV2ProxyRequest;
import com.amazonaws.serverless.proxy.spring.SpringBootLambdaContainerHandler;
import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestStreamHandler;
import io.lumigo.handlers.LumigoConfiguration;
import io.lumigo.handlers.LumigoRequestExecutor;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.function.Supplier;

public class FooLambdaHandler implements RequestStreamHandler {
  private static final SpringBootLambdaContainerHandler<HttpApiV2ProxyRequest, AwsProxyResponse>
      handler;

  static {
    LumigoConfiguration.builder().build().init();

    try {
      handler =
          SpringBootLambdaContainerHandler.getHttpApiV2ProxyHandler(FooApplication.class);
    } catch (ContainerInitializationException e) {
      // Re-throw the exception to force another cold start
      throw new HandlerInitException("Could not initialize Spring Boot application", e);
    }
  }

  @Override
  public void handleRequest(InputStream input, OutputStream output, Context context)
      throws RuntimeException {
    Supplier<OutputStream> supplier =
        () -> {
          OutputStream response;
          try {
            handler.proxyStream(input, output, context);
            response = output;

            // just in case it wasn't closed by the mapper
            output.close();
          } catch (IOException e) {
            throw new HandlerInitException("Could not run Handler", e);
          }

          return response;
        };

    LumigoRequestExecutor.execute(input, context, supplier);
  }
}
