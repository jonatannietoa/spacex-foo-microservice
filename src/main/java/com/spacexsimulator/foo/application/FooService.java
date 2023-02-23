package com.spacexsimulator.foo.application;

import com.spacexsimulator.foo.application.commandmodel.FooCommandModelOutput;
import com.spacexsimulator.foo.domain.exceptions.FooException;

public interface FooService {
  FooCommandModelOutput check() throws FooException;
}
