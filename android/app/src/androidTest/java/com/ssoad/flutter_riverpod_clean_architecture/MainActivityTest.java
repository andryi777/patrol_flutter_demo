package com.ssoad.flutter_riverpod_clean_architecture;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;
import org.junit.runners.Parameterized.Parameters;

import pl.leancode.patrol.PatrolJUnitRunner;

@RunWith(Parameterized.class)
public class MainActivityTest {
    private static PatrolJUnitRunner instrumentation;

    @Parameters(name = "{0}")
    public static Object[] testCases() {
        instrumentation = new PatrolJUnitRunner();
        instrumentation.setUp(MainActivity.class);
        instrumentation.waitForPatrolAppService();
        return instrumentation.listDartTests();
    }

    public MainActivityTest(String dartTestName) {
        this.dartTestName = dartTestName;
    }

    private final String dartTestName;

    @Test
    public void runDartTest() {
        instrumentation.runDartTest(dartTestName);
    }
}
