export function eagerLoadControllersFrom(context, application) {
  for (const key of context.keys()) {
    const controller = context(key).default
    application.register(controller.name, controller)
  }
}