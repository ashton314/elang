use std::collections::HashMap;

use inkwell::builder::Builder;
use inkwell::context::Context;
use inkwell::module::Module;
use inkwell::execution_engine::{JitFunction, ExecutionEngine};
use inkwell::passes::PassManager;
use inkwell::types::BasicMetadataTypeEnum;
use inkwell::values::{BasicValue, BasicMetadataValueEnum, FloatValue, FunctionValue, PointerValue};
use inkwell::{OptimizationLevel, FloatPredicate, AddressSpace};

use std::error::Error;

type JustANum = unsafe extern "C" fn () -> u64;

struct CodeGen<'ctx> {
    context: &'ctx Context,
    module: Module<'ctx>,
    builder: Builder<'ctx>,
    execution_engine: ExecutionEngine<'ctx>,
}

impl<'ctx> CodeGen<'ctx> {
    fn compile(&self) -> Option<JitFunction<JustANum>> {
        let i64_type = self.context.i64_type();
        let fn_type = i64_type.fn_type(&[], false);
        let function = self.module.add_function("just_a_num", fn_type, None);
        let basic_block = self.context.append_basic_block(function, "entry");

        let answer = i64_type.const_int(42, false);

        self.builder.position_at_end(basic_block);
        self.builder.build_return(Some(&answer));

        self.module.print_to_stderr();

        unsafe { self.execution_engine.get_function("just_a_num").ok() }
    }
}

pub struct Compiler<'a, 'ctx> {
    pub context: &'ctx Context,
    pub builder: &'a Builder<'ctx>,
    pub fpm: &'a PassManager<FunctionValue<'ctx>>,
    pub module: &'a Module<'ctx>,
    // pub function: &'a Function,

    // fn_value_opt: Option<FunctionValue<'ctx>>,
    variables: HashMap<String, PointerValue<'ctx>>
}

pub fn comp() -> Result<(), Box<dyn Error>> {
    let context = Context::create();
    let module  = context.create_module("foo");
    let execution_engine = module.create_jit_execution_engine(OptimizationLevel::None)?;
    let codegen = CodeGen {
        context: &context,
        module,
        builder: context.create_builder(),
        execution_engine
    };

    let code = codegen.compile().ok_or("Unable to JIT compile")?;

    unsafe {
        dbg!(code.call());
    }

    Ok(())
}
