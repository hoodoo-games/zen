import "./style.css";
import Zen, { Attribute } from "./zen";

class Hitpoints extends Attribute {
  value: number = 100;
}

const e1 = Zen.Entities.createEntity();
Zen.Entities.setAttribute(Hitpoints, e1, new Hitpoints());

const hp = Zen.Entities.getAttribute<Hitpoints>(Hitpoints, e1);
console.log(hp);
