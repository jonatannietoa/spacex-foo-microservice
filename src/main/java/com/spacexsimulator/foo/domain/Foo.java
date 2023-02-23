package com.spacexsimulator.foo.domain;

import com.spacexsimulator.foo.domain.exceptions.FooException;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Setter
@Getter
@AllArgsConstructor
@NoArgsConstructor
public class Foo {
  private String var1;
  private String var2;
  private String internalToken;

}
