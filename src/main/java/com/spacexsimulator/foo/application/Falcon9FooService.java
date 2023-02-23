package com.spacexsimulator.foo.application;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.spacexsimulator.foo.application.commandmodel.FooCommandModelOutput;
import com.spacexsimulator.foo.domain.Foo;
import com.spacexsimulator.foo.domain.exceptions.FooException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class Falcon9FooService implements FooService {

  private ObjectMapper objectMapper;

  @Autowired
  public Falcon9FooService(ObjectMapper objectMapper) {
    this.objectMapper = objectMapper;
  }

  @Override
  public FooCommandModelOutput check() throws FooException {
    Foo foo = new Foo("Test", "Trol", "JWTToken");

    return objectMapper.convertValue(foo, FooCommandModelOutput.class);
  }
}
