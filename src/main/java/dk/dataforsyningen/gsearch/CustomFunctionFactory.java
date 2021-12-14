package dk.dataforsyningen.gsearch;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import org.geotools.feature.NameImpl;
import org.geotools.filter.FunctionFactory;
import org.opengis.feature.type.Name;
import org.opengis.filter.capability.FunctionName;
import org.opengis.filter.expression.Expression;
import org.opengis.filter.expression.Function;
import org.opengis.filter.expression.Literal;

public class CustomFunctionFactory implements FunctionFactory {
    public List<FunctionName> getFunctionNames() {
        List<FunctionName> functionList = new ArrayList<>();
        functionList.add(AnyFunction.NAME);
        return Collections.unmodifiableList(functionList);
    }

    public Function function(String name, List<Expression> args, Literal fallback) {
        return function(new NameImpl(name), args, fallback);
    }

    public Function function(Name name, List<Expression> args, Literal fallback) {
        if (AnyFunction.NAME.getFunctionName().equals(name))
            return new AnyFunction(args);
        return null;
    }
}
