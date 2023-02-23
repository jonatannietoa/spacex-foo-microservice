package com.spacexsimulator.foo.domain;

import com.spacexsimulator.foo.domain.exceptions.FooException;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Setter
@Getter
@NoArgsConstructor
public class Foo {
    private String var1;
    private String var2;
    private String internalToken;

    public Foo(String var1, String var2, String internalToken) throws FooException {
        this.var1 = var1;
        checkVar(var2);
        this.var2 = var2;
        this.internalToken = internalToken;
    }

    public void setVar2(String var2) throws FooException {
        checkVar(var2);
    }

    private void checkVar(String var2) throws FooException {
        if (var2.equals("Trol")) {
            this.var2 = var2;
        }
        throw new FooException("Failure");
    }
}
