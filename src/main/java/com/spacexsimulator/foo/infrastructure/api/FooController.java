package com.spacexsimulator.foo.infrastructure.api;

import com.spacexsimulator.foo.application.FooService;
import com.spacexsimulator.foo.application.commandmodel.FooCommandModelOutput;
import com.spacexsimulator.foo.domain.exceptions.FooException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class FooController {

    private FooService fooService;

    @Autowired
    public FooController(FooService fooService) {
        this.fooService = fooService;
    }

    @GetMapping("/api/foo/check")
    ResponseEntity<FooCommandModelOutput> check() throws FooException {
        return new ResponseEntity<>(fooService.check(), HttpStatus.OK);
    }
}
